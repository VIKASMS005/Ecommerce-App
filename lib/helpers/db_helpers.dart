import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DbHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE profile_pic(id TEXT PRIMARY KEY,image TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertPic(String table, Map<String, Object> data) async {
    final db = await DbHelper.database();
    db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> fetchProfilePic(String uid) async {
    final db = await DbHelper.database();

    final result = await db.query(
      'profile_pic',
      where: 'id = ?',
      whereArgs: [uid],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }
}
