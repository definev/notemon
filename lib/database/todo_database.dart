import 'package:gottask/database/todo_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoDatabase {
  static const DB_NAME = 'tododb.db';
  static const DB_VERSION = 2;
  static Database _database;

  TodoDatabase._internal();
  static final TodoDatabase instance = TodoDatabase._internal();

  Database get database => _database;

  static const initScripts = [
    TodoTable.CREATE_TABLE_QUERY,
    TodoTable.CREATE_DELETE_TABLE_QUERY
  ];
  static const migrationScripts = [
    TodoTable.MIGRATE_DATABASE_QUERY,
  ];

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
