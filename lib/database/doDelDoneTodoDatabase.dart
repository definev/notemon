import 'package:gottask/database/doDelDoneTodoTable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DoDelDoneTodoDatabase {
  static const DB_NAME = 'dodeldonetodo.db';
  static const DB_VERSION = 1;
  static Database _database;

  DoDelDoneTodoDatabase._internal();
  static final DoDelDoneTodoDatabase instance =
      DoDelDoneTodoDatabase._internal();

  Database get database => _database;

  static const initScripts = [DoDelDoneTodoTable.CREATE_TABLE_QUERY];
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
