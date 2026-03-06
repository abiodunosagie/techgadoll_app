import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class ProductCache {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'product_cache.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_responses (
            cache_key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> put(String key, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'cached_responses',
      {
        'cache_key': key,
        'data': jsonEncode(data),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> get(String key) async {
    final db = await database;
    final results = await db.query(
      'cached_responses',
      where: 'cache_key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final cachedAt = row['cached_at'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;

    // Cache valid for 30 minutes
    if (age > 30 * 60 * 1000) {
      await db.delete('cached_responses', where: 'cache_key = ?', whereArgs: [key]);
      return null;
    }

    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  static Future<bool> hasValidCache(String key) async {
    final data = await get(key);
    return data != null;
  }

  static Future<void> clear() async {
    final db = await database;
    await db.delete('cached_responses');
  }
}
