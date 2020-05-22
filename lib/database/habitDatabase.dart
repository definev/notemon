import 'package:gottask/database/habitTable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HabitDatabase {
  static const DB_NAME = 'habitdb.db';
  static const DB_VERSION = 1;
  static Database _database;

  HabitDatabase._internal();
  static final HabitDatabase instance = HabitDatabase._internal();

  Database get database => _database;

  static const initScripts = [HabitTable.CREATE_TABLE_QUERY];
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
