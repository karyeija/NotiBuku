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

      // Desktop ffi init (unchanged)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        // debugPrint('🔍 [DB] FFI initialized for desktop');
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, "notes_database.db");
      debugPrint('📱 [DB] Database path: $path');

      final db = await openDatabase(
        path,
        version: 6, // 🔥 MUST BE 6
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          debugPrint('✅ [DB] Database opened successfully');
        },
      );

      // debugPrint('✅ [DB] Database initialization complete');
      return db;
    } catch (e, stackTrace) {
      debugPrint('❌ [DB] initDatabase FAILED: $e');
      debugPrint('📍 [DB] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 🔥 DEBUG: Print table structure
  // static Future<void> _debugTableInfo(Database db) async {
  //   try {
  //     final columns = await db.rawQuery('PRAGMA table_info(notes)');
  //     debugPrint(
  //       '📋 [DB] Table "notes" columns: ${columns.map((c) => "${c['name']}: ${c['type']}").join(", ")}',
  //     );

  //     final count = Sqflite.firstIntValue(
  //       await db.rawQuery('SELECT COUNT(*) FROM notes'),
  //     );
  //     debugPrint('📊 [DB] Total notes count: $count');
  //   } catch (e) {
  //     debugPrint('⚠️ [DB] Could not debug table info: $e');
  //   }
  // }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔨 [DB] Creating new database...');
    await db.execute('''
  CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL, 
    content TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    color TEXT,
    titleTextColor TEXT,      -- 🔥 NEW: Title color
    contentTextColor TEXT,    -- 🔥 NEW: Content color
    titleFontFamily TEXT,
    contentFontFamily TEXT,
    titleFontSize REAL,
    contentFontSize REAL
  )
  ''');
    debugPrint('✅ [DB] Table created with titleTextColor + contentTextColor');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 [DB] Migrating from v$oldVersion → v$newVersion');

    // v1 → v2: Add color
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN color TEXT');
      debugPrint('✅ [DB] v2: Added color column');
    }

    // v2 → v3: Add textColor
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE notes ADD COLUMN textColor TEXT');
      debugPrint('✅ [DB] v3: Added textColor column');
    }

    // v3 → v4: Add font families
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE notes ADD COLUMN titleFontFamily TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN contentFontFamily TEXT');
      debugPrint('✅ [DB] v4: Added font family columns');
    }

    // v4 → v5: Add font sizes
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE notes ADD COLUMN titleFontSize REAL');
      await db.execute('ALTER TABLE notes ADD COLUMN contentFontSize REAL');
      debugPrint('✅ [DB] v5: Added font size columns');
    }

    // 🔥 v5 → v6: textColor → titleTextColor + contentTextColor
    if (oldVersion < 6) {
      debugPrint('🔥 [DB] v6: Migrating textColor → separate colors...');

      // Add new columns
      await db.execute('ALTER TABLE notes ADD COLUMN titleTextColor TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN contentTextColor TEXT');

      // Migrate existing data (copy textColor to both new columns)
      await db.execute('''
      UPDATE notes 
      SET titleTextColor = COALESCE(textColor, '#000000'),
          contentTextColor = COALESCE(textColor, '#000000')
      WHERE textColor IS NOT NULL
    ''');

      debugPrint('✅ [DB] v6: Migration complete! New columns ready.');
    }
  }

  // 🔥 SAVE OPERATIONS WITH FULL DEBUG
  static Future<int> addNote(Note note) async {
    try {
      // debugPrint('💾 [SAVE] Adding new note: "${note.title}"');
      // debugPrint('📝 [SAVE] Note data: ${note.toMap()}');

      final db = await DatabaseService.instance.database;
      final id = await db.insert('notes', note.toMap());

      // debugPrint('✅ [SAVE] Note saved with ID: $id');
      return id;
    } catch (e, stackTrace) {
      debugPrint('❌ [SAVE] addNote FAILED: $e');
      debugPrint('📍 [SAVE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<int> updateNote(Note note) async {
    try {
      debugPrint('🔄 [SAVE] Updating note ID: ${note.id}');
      debugPrint('📝 [SAVE] Update data: ${note.toMap()}');

      final db = await DatabaseService.instance.database;
      final rowsAffected = await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );

      debugPrint('✅ [SAVE] Updated $rowsAffected row(s)');
      return rowsAffected;
    } catch (e, stackTrace) {
      debugPrint('❌ [SAVE] updateNote FAILED: $e');
      debugPrint('📍 [SAVE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<int> deleteNote(int id) async {
    try {
      debugPrint('🗑️ [DELETE] Deleting note ID: $id');

      final db = await DatabaseService.instance.database;
      final rowsAffected = await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );

      debugPrint('✅ [DELETE] Deleted $rowsAffected row(s)');
      return rowsAffected;
    } catch (e, stackTrace) {
      debugPrint('❌ [DELETE] deleteNote FAILED: $e');
      debugPrint('📍 [DELETE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 🔥 LOAD OPERATIONS WITH FULL DEBUG
  static Future<List<Note>> getNotes() async {
    try {
      // debugPrint('📖 [LOAD] Fetching all notes...');

      final db = await DatabaseService.instance.database;
      final result = await db.query('notes', orderBy: 'createdAt DESC');

      // debugPrint('📊 [LOAD] Found ${result.length} raw rows');
      final notes = result.map((e) => Note.fromMap(e)).toList();

      // debugPrint('✅ [LOAD] Loaded ${notes.length} notes');
      return notes;
    } catch (e, stackTrace) {
      debugPrint('❌ [LOAD] getNotes FAILED: $e');
      debugPrint('📍 [LOAD] Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<Map<String, List<Note>>> getNotesGroupedByDay() async {
    try {
      // debugPrint('📅 [LOAD] Grouping notes by day...');
      final allNotes = await getNotes();
      final grouped = <String, List<Note>>{};

      for (final note in allNotes) {
        final day = DateTime.parse(
          note.createdAt,
        ).toIso8601String().split('T')[0];
        grouped.putIfAbsent(day, () => []).add(note);
      }

      // debugPrint('✅ [LOAD] Grouped into ${grouped.length} days');
      return grouped;
    } catch (e, stackTrace) {
      debugPrint('❌ [LOAD] getNotesGroupedByDay FAILED: $e');
      debugPrint('📍 [LOAD] Stack trace: $stackTrace');
      return {};
    }
  }

  // 🔥 DEBUG HELPER
  static Future<void> debugDumpAll() async {
    debugPrint('🔍 [DEBUG] === FULL DATABASE DUMP ===');
    final db = await DatabaseService.instance.database;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    debugPrint('📋 Tables: ${tables.map((t) => t['name']).toList()}');

    final notes = await getNotes();
    debugPrint('📝 Total notes: ${notes.length}');
    for (int i = 0; i < notes.length && i < 3; i++) {
      debugPrint('  Note ${notes[i].id}: "${notes[i].title}"');
    }
  }

  static Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, "notes_database.db");
  }
}
