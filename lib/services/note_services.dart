import 'package:notibuku/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static final _tableName = 'notes';
  static final _dbId = 'id';
  static final _dbTitle = 'title';
  static final _dbContent = 'content';
  static final _dbCreatedAt = 'createdAt';

  static Future<Database> _getDatabase() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            $_dbId INTEGER PRIMARY KEY, 
            $_dbTitle TEXT NOT NULL, 
            $_dbContent TEXT NOT NULL,
            $_dbCreatedAt TEXT NOT NULL
          )
        ''');
        // Optionally insert some initial data here
        // await db.insert(_tableName, {
        //   _dbTitle: 'Test',
        //   _dbContent: 'Good morning',
        //   _dbCreatedAt: DateTime.now().toIso8601String(),
        // });
      },
    );
    return _database!;
  }

  static Future<List<Note>> getNotes() async {
    final db = await _getDatabase();
    final result = await db.query(_tableName);
    return result.map((e) => Note.fromMap(e)).toList();
  }

  static Future<int> addNote(Note note) async {
    final db = await _getDatabase();
    return db.insert(_tableName, note.toMap());
  }

  static Future<int> updateNote(Note note) async {
    final db = await _getDatabase();
    return db.update(
      _tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<int> deleteNote(int id) async {
    final db = await _getDatabase();
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
