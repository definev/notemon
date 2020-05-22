import 'package:gottask/database/doDelDoneHabitTable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DoDelDoneHabitDatabase {
  static const DB_NAME = 'dodeldonehabit.db';
  static const DB_VERSION = 1;
  static Database _database;

  DoDelDoneHabitDatabase._internal();
  static final DoDelDoneHabitDatabase instance =
      DoDelDoneHabitDatabase._internal();

  Database get database => _database;

  static const initScripts = [DoDelDoneHabitTable.CREATE_TABLE_QUERY];
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
