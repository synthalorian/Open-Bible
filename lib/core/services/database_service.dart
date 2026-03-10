import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'verse_storage_service.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'saved_verses';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'open_bible_v1.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            type TEXT, -- 'bookmark', 'highlight', 'note'
            data TEXT, -- JSON string of SavedVerse
            saved_at INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> saveVerse(SavedVerse verse, String type) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        'id': verse.id,
        'type': type,
        'data': json.encode(verse.toJson()),
        'saved_at': verse.savedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeVerse(String id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<SavedVerse>> getAllByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'saved_at DESC',
    );
    return maps.map((m) => SavedVerse.fromJson(json.decode(m['data']))).toList();
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableName);
  }
}
