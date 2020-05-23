import 'package:gottask/database/doDelDoneHabitDatabase.dart';
import 'package:gottask/models/do_del_done_task.dart';
import 'package:sqflite/sqflite.dart';

class DoDelDoneTaskTable {
  static const TABLE_NAME = 'DoDelDoneTaskdb';

  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id INTEGER,
      doTask INTEGER,
      delTask INTEGER,
      doneTask INTEGER
    );   
  ''';
  static const DROP_TABLE_QUERY = '''
      DROP TABLE IF EXISTS $TABLE_NAME
  ''';

  Future<int> insertTask(DoDelDoneTask doDelDoneTask) {
    Database database = DoDelDoneTaskDatabase.instance.database;
    return database.insert(
      TABLE_NAME,
      doDelDoneTask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDoDelDoneTask(DoDelDoneTask doDelDoneTask) {
    final Database db = DoDelDoneTaskDatabase.instance.database;
    print('update ${doDelDoneTask.toMap().toString()}');
    return db.update(
      TABLE_NAME,
      doDelDoneTask.toMap(),
      where: 'id = ?',
      whereArgs: [doDelDoneTask.id],
    );
  }

  Future<DoDelDoneTask> selectDoDelDoneTask() async {
    final Database db = DoDelDoneTaskDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query('$TABLE_NAME');
    if (map.length == 0) {
      await insertTask(
        DoDelDoneTask(
          id: 1,
          delTask: 0,
          doneTask: 0,
          doTask: 0,
        ),
      );
      return DoDelDoneTask(
        id: 1,
        delTask: 0,
        doneTask: 0,
        doTask: 0,
      );
    }
    return DoDelDoneTask(
      id: 1,
      delTask: map[0]['delTask'],
      doneTask: map[0]['doneTask'],
      doTask: map[0]['doTask'],
    );
  }
}
