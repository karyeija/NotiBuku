import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:notibuku/models/note.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  static Database? get instanceDb => _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    try {
      debugPrint('🔍 [DB] Initializing database...');

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        debugPrint('🖥️ [DB] FFI enabled for desktop');
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, "notes_database.db");
      debugPrint('📱 [DB] Database path: $path');

      final db = await openDatabase(
        path,
        version: 8,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          debugPrint(' [DB] Database opened successfully');
          await _verifyAndFixMigration(db);
          await _verifyTodoMigration(db);
        },
      );

      return db;
    } catch (e) {
      debugPrint('❌ [DB] initDatabase FAILED: $e');
      rethrow;
    }
  }

  Future<void> _verifyAndFixMigration(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(notes)');
      final hasCategory = columns.any((column) => column['name'] == 'category');

      if (!hasCategory) {
        debugPrint('🚨 [FIX] Category column MISSING - Adding NOW!');
        await db.execute(
          'ALTER TABLE notes ADD COLUMN category TEXT DEFAULT "Personal"',
        );
        await db.execute('PRAGMA user_version = 7');
        debugPrint(' [FIX] Category column added + version=7');
      } else {
        debugPrint(
          ' [CHECK] Category column exists (${columns.length} total columns)',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [CHECK] Migration check failed: $e');
    }
  }

  Future<void> _verifyTodoMigration(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(notes)');
      final hasIsCompleted = columns.any(
        (column) => column['name'] == 'is_completed',
      );

      if (!hasIsCompleted) {
        debugPrint('🚨 [FIX] is_completed column MISSING - Adding NOW!');
        await db.execute(
          'ALTER TABLE notes ADD COLUMN is_completed INTEGER DEFAULT 0',
        );
        debugPrint(' [FIX] is_completed column added');
      } else {
        debugPrint(' [CHECK] is_completed column exists');
      }
    } catch (e) {
      debugPrint('⚠️ [CHECK] Todo migration check failed: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔨 [DB] Creating new database...');
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL, 
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        color TEXT,
        titleTextColor TEXT,
        contentTextColor TEXT,
        titleFontFamily TEXT,
        contentFontFamily TEXT,
        titleFontSize REAL,
        contentFontSize REAL,
        category TEXT DEFAULT "Personal",
        is_completed INTEGER DEFAULT 0
      )
    ''');
    debugPrint(' [DB] Table created with ALL columns including is_completed');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 [DB] Migrating from v$oldVersion → v$newVersion');

    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN color TEXT');
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE notes ADD COLUMN textColor TEXT');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE notes ADD COLUMN titleFontFamily TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN contentFontFamily TEXT');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE notes ADD COLUMN titleFontSize REAL');
      await db.execute('ALTER TABLE notes ADD COLUMN contentFontSize REAL');
    }

    if (oldVersion < 6) {
      debugPrint('🔥 [DB] v6: Migrating textColor → separate colors...');
      await db.execute('ALTER TABLE notes ADD COLUMN titleTextColor TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN contentTextColor TEXT');

      await db.execute('''
        UPDATE notes 
        SET titleTextColor = COALESCE(textColor, '#000000'),
            contentTextColor = COALESCE(textColor, '#000000')
        WHERE textColor IS NOT NULL
      ''');

      debugPrint(' [DB] v6: Migration complete!');
    }

    if (oldVersion < 7) {
      await db.execute(
        'ALTER TABLE notes ADD COLUMN category TEXT DEFAULT "Personal"',
      );
      debugPrint(' [DB] v7: Added category column');
    }

    if (oldVersion < 8) {
      debugPrint(' [DB] v8: Adding is_completed column...');
      await db.execute(
        'ALTER TABLE notes ADD COLUMN is_completed INTEGER DEFAULT 0',
      );
      debugPrint(' [DB] v8: is_completed column added!');
    }
  }

  static Future<void> _ensureSchemaReady(Database db) async {
    try {
      await db.rawQuery(
        'SELECT category, is_completed FROM notes WHERE 1 LIMIT 1',
      );
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('no column named category')) {
        debugPrint('🚨 [EMERGENCY] Adding category column...');
        await db.execute(
          'ALTER TABLE notes ADD COLUMN category TEXT DEFAULT "Personal"',
        );
      }
      if (errorStr.contains('no column named is_completed')) {
        debugPrint('🚨 [EMERGENCY] Adding is_completed column...');
        await db.execute(
          'ALTER TABLE notes ADD COLUMN is_completed INTEGER DEFAULT 0',
        );
      }
    }
  }

  static Future<List<Note>> getAllNotes() async {
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.query('notes', orderBy: 'createdAt DESC');

      final notes = result.map((e) => Note.fromMap(e)).toList();
      debugPrint('📊 [SEARCH] Loaded ${notes.length} notes for filtering');
      return notes;
    } catch (e) {
      debugPrint('❌ [SEARCH] getAllNotes FAILED: $e');
      return [];
    }
  }

  static Future<List<Note>> searchNotes(String query) async {
    try {
      if (query.isEmpty) return getAllNotes();

      final db = await DatabaseService.instance.database;
      final result = await db.query(
        'notes',
        where: 'LOWER(title) LIKE ? OR LOWER(content) LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'createdAt DESC',
      );

      final notes = result.map((e) => Note.fromMap(e)).toList();
      debugPrint('🔍 [SEARCH] Found ${notes.length} notes matching "$query"');
      return notes;
    } catch (e) {
      debugPrint('❌ [SEARCH] searchNotes FAILED: $e');
      return [];
    }
  }

  static Future<List<Note>> getNotesByDate(String dateStr) async {
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.query(
        'notes',
        where: 'DATE(createdAt) = ?',
        whereArgs: [dateStr],
        orderBy: 'createdAt DESC',
      );

      final notes = result.map((e) => Note.fromMap(e)).toList();
      debugPrint('📅 [DATE] Found ${notes.length} notes on $dateStr');
      return notes;
    } catch (e) {
      debugPrint('❌ [DATE] getNotesByDate FAILED: $e');
      return [];
    }
  }

  static Future<int> addNote(Note note) async {
    try {
      final db = await DatabaseService.instance.database;
      await _ensureSchemaReady(db);

      final id = await db.insert('notes', note.toMap());
      debugPrint('💾 [SAVE] New note ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ [SAVE] addNote FAILED: $e');
      rethrow;
    }
  }

  static Future<int> updateNote(Note note) async {
    try {
      final db = await DatabaseService.instance.database;
      final rowsAffected = await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      debugPrint('🔄 [SAVE] Updated note ${note.id}: $rowsAffected rows');
      return rowsAffected;
    } catch (e) {
      debugPrint('❌ [SAVE] updateNote FAILED: $e');
      rethrow;
    }
  }

  static Future<void> toggleNoteCompletion(int id, bool isCompleted) async {
    try {
      final db = await DatabaseService.instance.database;
      await db.update(
        'notes',
        {'is_completed': isCompleted ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint(' [TODO] Toggled note $id completion: $isCompleted');
    } catch (e) {
      debugPrint('❌ [TODO] toggleNoteCompletion FAILED: $e');
      rethrow;
    }
  }

  static Future<int> deleteNote(int id) async {
    try {
      final db = await DatabaseService.instance.database;
      final rowsAffected = await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('🗑️ [DELETE] Note $id: $rowsAffected rows');
      return rowsAffected;
    } catch (e) {
      debugPrint('❌ [DELETE] deleteNote FAILED: $e');
      rethrow;
    }
  }

  static Future<List<Note>> getNotes() async {
    return await getAllNotes();
  }

  static Future<Map<String, List<Note>>> getNotesGroupedByDay() async {
    try {
      final allNotes = await getAllNotes();
      final grouped = <String, List<Note>>{};

      for (final note in allNotes) {
        final dayKey = note.createdAt.substring(0, 10);
        grouped.putIfAbsent(dayKey, () => []).add(note);
      }

      debugPrint(
        '📅 [GROUP] Grouped ${allNotes.length} notes into ${grouped.length} days',
      );
      return grouped;
    } catch (e) {
      debugPrint('❌ [GROUP] getNotesGroupedByDay FAILED: $e');
      return {};
    }
  }

  static Future<void> debugDumpAll() async {
    debugPrint('🔍 [DEBUG] === FULL DATABASE DUMP ===');
    final db = await DatabaseService.instance.database;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    debugPrint('📋 Tables: ${tables.map((t) => t['name']).toList()}');

    final notes = await getAllNotes();
    debugPrint('📝 Total notes: ${notes.length}');
    for (int i = 0; i < notes.length && i < 5; i++) {
      final note = notes[i];
      debugPrint(
        '  Note ${note.id}: "${note.title}" (${note.createdAt}) '
        'category: "${note.category}" ${note.isCompleted == true ? "DONE" : "PENDING"}',
      );
    }
  }

  static Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, "notes_database.db");
  }
}
