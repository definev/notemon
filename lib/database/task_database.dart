import 'package:gottask/database/task_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDatabase {
  static const DB_NAME = 'Taskdb.db';
  static const DB_VERSION = 1;
  static Database _database;

  TaskDatabase._internal();
  static final TaskDatabase instance = TaskDatabase._internal();

  Database get database => _database;

  static const initScripts = [
    TaskTable.CREATE_TABLE_QUERY,
    TaskTable.CREATE_DELETE_TABLE_QUERY,
  ];
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
