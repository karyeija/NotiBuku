import 'dart:convert';
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

  static const int _databaseVersion = 10;
  static const String _databaseName = 'notes_database.db';
  static const String _notesTable = 'notes';

  static bool _ffiInitialized = false;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  // --------------------------------------------------
  // SCHEMA
  // --------------------------------------------------

  Future<void> _onCreate(Database db, int version) async {
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
        category TEXT DEFAULT 'Personal',
        is_completed INTEGER DEFAULT 0,
        todoList TEXT DEFAULT '[]',
        isChecklist INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Repair the schema using actual table columns.
    await _ensureCurrentSchema(db);
  }

  Future<void> _onOpen(Database db) async {
    await _ensureCurrentSchema(db);
  }

  Future<Set<String>> _getColumnNames(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info($_notesTable)');

    return columns.map((column) => column['name'] as String).toSet();
  }

  Future<bool> _addColumnIfMissing(
    Database db,
    Set<String> columns,
    String name,
    String definition,
  ) async {
    if (columns.contains(name)) {
      return false;
    }

    await db.execute('ALTER TABLE $_notesTable ADD COLUMN $name $definition');

    columns.add(name);
    return true;
  }

  Future<void> _ensureCurrentSchema(Database db) async {
    final tables = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name = ?
      ''',
      [_notesTable],
    );

    // Create the complete schema only if the notes table is missing.
    if (tables.isEmpty) {
      await _onCreate(db, _databaseVersion);
      return;
    }

    final columns = await _getColumnNames(db);

    await _addColumnIfMissing(db, columns, 'color', 'TEXT');

    await _addColumnIfMissing(db, columns, 'textColor', 'TEXT');

    await _addColumnIfMissing(db, columns, 'titleFontFamily', 'TEXT');

    await _addColumnIfMissing(db, columns, 'contentFontFamily', 'TEXT');

    await _addColumnIfMissing(db, columns, 'titleFontSize', 'REAL');

    await _addColumnIfMissing(db, columns, 'contentFontSize', 'REAL');

    await _addColumnIfMissing(db, columns, 'titleTextColor', 'TEXT');

    await _addColumnIfMissing(db, columns, 'contentTextColor', 'TEXT');

    await _addColumnIfMissing(
      db,
      columns,
      'category',
      "TEXT DEFAULT 'Personal'",
    );

    await _addColumnIfMissing(db, columns, 'is_completed', 'INTEGER DEFAULT 0');

    await _addColumnIfMissing(db, columns, 'todoList', "TEXT DEFAULT '[]'");

    // Fix the reported error: existing databases may lack this column.
    final checklistColumnAdded = await _addColumnIfMissing(
      db,
      columns,
      'isChecklist',
      'INTEGER NOT NULL DEFAULT 0',
    );

    // Preserve legacy text colors when migrating older databases.
    if (columns.contains('textColor')) {
      await db.execute('''
        UPDATE notes
        SET
          titleTextColor =
            COALESCE(titleTextColor, textColor, '#000000'),
          contentTextColor =
            COALESCE(contentTextColor, textColor, '#000000')
        WHERE textColor IS NOT NULL
      ''');
    }

    // Backfill checklist status only when the column is first added.
    // Existing notes and their checklist JSON are retained.
    if (checklistColumnAdded) {
      await _backfillChecklistStatus(db);
    }
  }

  Future<void> _backfillChecklistStatus(Database db) async {
    final rows = await db.query(
      _notesTable,
      columns: ['id', 'category', 'todoList'],
    );

    for (final row in rows) {
      final id = row['id'];
      final category = (row['category'] as String? ?? '').trim().toLowerCase();

      final rawTodoList = row['todoList'];
      var hasTasks = false;

      try {
        final decoded = rawTodoList is String
            ? jsonDecode(rawTodoList)
            : rawTodoList;

        hasTasks = decoded is List && decoded.isNotEmpty;
      } catch (_) {
        // Malformed legacy JSON must not prevent the database opening.
      }

      // To-Do category notes and notes with existing tasks are checklists.
      if (category == 'to-do' || hasTasks) {
        await db.update(
          _notesTable,
          {'isChecklist': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  // Retained for compatibility with existing calls.
  static Future<void> _ensureSchemaReady(Database db) async {
    await instance._ensureCurrentSchema(db);
  }

  // --------------------------------------------------
  // SERIALIZATION
  // --------------------------------------------------

  static Map<String, dynamic> _decodeNoteRow(Map<String, dynamic> rawRow) {
    final row = Map<String, dynamic>.from(rawRow);
    final rawTodoList = row['todoList'];

    if (rawTodoList is String) {
      try {
        final decoded = jsonDecode(rawTodoList);
        row['todoList'] = decoded is List ? decoded : <dynamic>[];
      } catch (_) {
        // Recover from malformed JSON without losing the note.
        row['todoList'] = <dynamic>[];
      }
    } else if (rawTodoList is! List) {
      row['todoList'] = <dynamic>[];
    }

    // Support older rows and legacy checklist data.
    final rawChecklist = row['isChecklist'];
    final storedChecklist = rawChecklist == 1 || rawChecklist == true;

    final todoList = row['todoList'] as List;
    final category = (row['category'] as String? ?? '').trim().toLowerCase();

    row['isChecklist'] =
        storedChecklist || todoList.isNotEmpty || category == 'to-do';

    return row;
  }

  static List<Note> _mapNotes(List<Map<String, dynamic>> rows) {
    return rows.map((row) => Note.fromMap(_decodeNoteRow(row))).toList();
  }

  static Map<String, dynamic> _encodeNote(Note note) {
    final map = Map<String, dynamic>.from(note.toMap());

    final todoList = map['todoList'];

    map['todoList'] = jsonEncode(todoList is List ? todoList : <dynamic>[]);

    // Store SQLite booleans as integers.
    map['isChecklist'] = map['isChecklist'] == true || map['isChecklist'] == 1
        ? 1
        : 0;

    return map;
  }

  // --------------------------------------------------
  // READ
  // --------------------------------------------------

  static Future<List<Note>> getAllNotes() async {
    final db = await instance.database;

    final rows = await db.query(_notesTable, orderBy: 'createdAt DESC');

    return _mapNotes(rows);
  }

  static Future<List<Note>> getNotes() async {
    return getAllNotes();
  }

  static Future<List<Note>> searchNotes(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return getAllNotes();
    }

    final db = await instance.database;
    final pattern = '%${trimmedQuery.toLowerCase()}%';

    final rows = await db.query(
      _notesTable,
      where: 'LOWER(title) LIKE ? OR LOWER(content) LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'createdAt DESC',
    );

    return _mapNotes(rows);
  }

  static Future<List<Note>> getNotesByDate(String dateStr) async {
    final db = await instance.database;

    final rows = await db.query(
      _notesTable,
      where: 'DATE(createdAt) = ?',
      whereArgs: [dateStr],
      orderBy: 'createdAt DESC',
    );

    return _mapNotes(rows);
  }

  static Future<Map<String, List<Note>>> getNotesGroupedByDay() async {
    final notes = await getAllNotes();
    final grouped = <String, List<Note>>{};

    for (final note in notes) {
      final createdAt = DateTime.tryParse(note.createdAt);

      final dayKey = createdAt != null
          ? '${createdAt.year.toString().padLeft(4, '0')}-'
                '${createdAt.month.toString().padLeft(2, '0')}-'
                '${createdAt.day.toString().padLeft(2, '0')}'
          : note.createdAt.length >= 10
          ? note.createdAt.substring(0, 10)
          : note.createdAt;

      grouped.putIfAbsent(dayKey, () => []).add(note);
    }

    return grouped;
  }

  // --------------------------------------------------
  // WRITE
  // --------------------------------------------------

  static Future<int> addNote(Note note) async {
    final db = await instance.database;
    await _ensureSchemaReady(db);

    final map = _encodeNote(note);

    // Let SQLite generate the primary key for new notes.
    map.remove('id');

    return db.insert(
      _notesTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<int> updateNote(Note note) async {
    final db = await instance.database;
    await _ensureSchemaReady(db);

    final map = _encodeNote(note);

    // Never update the primary key during an edit.
    map.remove('id');

    return db.update(_notesTable, map, where: 'id = ?', whereArgs: [note.id]);
  }

  static Future<void> toggleNoteCompletion(int id, bool isCompleted) async {
    final db = await instance.database;
    await _ensureSchemaReady(db);

    await db.update(
      _notesTable,
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteNote(int id) async {
    final db = await instance.database;

    return db.delete(_notesTable, where: 'id = ?', whereArgs: [id]);
  }

  // --------------------------------------------------
  // DEBUG / TOOLS
  // --------------------------------------------------

  static Future<void> debugDumpAll() async {
    final db = await instance.database;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    debugPrint('Tables: ${tables.map((table) => table['name']).toList()}');

    final notes = await getAllNotes();

    debugPrint('Total notes: ${notes.length}');

    for (final note in notes.take(5)) {
      debugPrint(
        'Note ${note.id}: "${note.title}" '
        '(${note.createdAt}), '
        'category: "${note.category}", '
        'status: ${note.isCompleted == true ? "DONE" : "PENDING"}, '
        'isChecklist: ${note.isChecklist}, '
        'checklist items: ${note.todoList.length}',
      );
    }
  }

  static Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();

    return join(directory.path, _databaseName);
  }

  static Future<void> debugTodoNote(String title) async {
    final db = await instance.database;

    final rows = await db.query(
      _notesTable,
      where: 'title = ?',
      whereArgs: [title],
    );

    for (final row in rows) {
      debugPrint('--- TODO NOTE DIAGNOSTIC ---');
      debugPrint('ID: ${row['id']}');
      debugPrint('Title: ${row['title']}');
      debugPrint('Category: ${row['category']}');
      debugPrint('isChecklist: ${row['isChecklist']}');
      debugPrint('Raw todoList: ${row['todoList']}');

      final decoded = _decodeNoteRow(row);
      final note = Note.fromMap(decoded);

      debugPrint('Decoded task count: ${note.todoList.length}');
      debugPrint(
        'Decoded tasks: ${note.todoList.map((item) => item.text).toList()}',
      );
    }
  }
}
