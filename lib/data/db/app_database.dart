import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'warmup.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            createdAt TEXT NOT NULL,
            promptText TEXT NOT NULL,
            transcript TEXT NOT NULL,
            wordCount INTEGER NOT NULL,
            durationSeconds REAL NOT NULL,
            wordsPerMinute REAL NOT NULL,
            fillerCount INTEGER NOT NULL,
            fillerBreakdown TEXT NOT NULL,
            clutchWordCount INTEGER NOT NULL,
            longPauseCount INTEGER NOT NULL,
            score INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}
