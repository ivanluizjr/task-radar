import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_radar.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY,
            todo TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            userId INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL,
            image TEXT,
            role TEXT NOT NULL DEFAULT 'moderator'
          )
        ''');

        await db.execute('''
          CREATE TABLE deleted_todos (
            id INTEGER PRIMARY KEY
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_todos_userId ON todos(userId)
        ''');

        await db.execute('''
          CREATE INDEX idx_todos_completed ON todos(completed)
        ''');

        await db.execute('''
          CREATE INDEX idx_deleted_todos_id ON deleted_todos(id)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS deleted_todos (
              id INTEGER PRIMARY KEY
            )
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_deleted_todos_id ON deleted_todos(id)
          ''');
        }
      },
    );
  }
}
