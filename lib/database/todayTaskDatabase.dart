import 'package:gottask/database/todayTaskTable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodayTaskDatabase {
  static const DB_NAME = 'todaytaskdb.db';
  static const DB_VERSION = 1;
  static Database _database;

  TodayTaskDatabase._internal();
  static final TodayTaskDatabase instance = TodayTaskDatabase._internal();

  Database get database => _database;

  static const initScripts = [TodayTaskTable.CREATE_TABLE_QUERY];
  static const migrationScripts = [];

  init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) {
        initScripts.forEach((script) async => await db.execute(script));
      },
      onUpgrade: (db, oldVersion, newVersion) {
        migrationScripts.forEach((script) async => await db.execute(script));
      },
      version: DB_VERSION,
    );
  }
}
