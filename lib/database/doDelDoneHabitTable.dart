import 'package:gottask/database/doDelDoneHabitDatabase.dart';
import 'package:gottask/models/do_del_done_habit.dart';
import 'package:sqflite/sqflite.dart';

class DoDelDoneHabitTable {
  static const TABLE_NAME = 'DoDelDoneHabitdb';

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

  Future<int> insertHabit(DoDelDoneHabit doDelDoneHabit) {
    Database database = DoDelDoneHabitDatabase.instance.database;
    return database.insert(
      TABLE_NAME,
      doDelDoneHabit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDoDelDoneHabit(DoDelDoneHabit doDelDoneHabit) {
    final Database db = DoDelDoneHabitDatabase.instance.database;
    print('update ${doDelDoneHabit.toMap().toString()}');
    return db.update(
      TABLE_NAME,
      doDelDoneHabit.toMap(),
      where: 'id = ?',
      whereArgs: [doDelDoneHabit.id],
    );
  }

  Future<DoDelDoneHabit> selectDoDelDoneHabit() async {
    final Database db = DoDelDoneHabitDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query('$TABLE_NAME');
    if (map.length == 0) {
      await insertHabit(
        DoDelDoneHabit(
          id: 1,
          delTask: 0,
          doneTask: 0,
          doTask: 0,
        ),
      );
      return DoDelDoneHabit(
        id: 1,
        delTask: 0,
        doneTask: 0,
        doTask: 0,
      );
    }
    return DoDelDoneHabit(
      id: 1,
      delTask: map[0]['delTask'],
      doneTask: map[0]['doneTask'],
      doTask: map[0]['doTask'],
    );
  }
}
