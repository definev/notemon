import 'package:gottask/database/doDelDoneHabitTable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DoDelDoneTaskDatabase {
  static const DB_NAME = 'dodeldoneTask.db';
  static const DB_VERSION = 1;
  static Database _database;

  DoDelDoneTaskDatabase._internal();
  static final DoDelDoneTaskDatabase instance =
      DoDelDoneTaskDatabase._internal();

  Database get database => _database;

  static const initScripts = [DoDelDoneTaskTable.CREATE_TABLE_QUERY];
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
