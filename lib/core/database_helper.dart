import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'daily_pulse.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mood_entries (
            id TEXT PRIMARY KEY,
            userId TEXT,
            date TEXT,
            moodType TEXT,
            emoji TEXT,
            note TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            deleted INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
