import 'package:gottask/database/doDelDoneTodoDatabase.dart';
import 'package:gottask/models/do_del_done_task.dart';
import 'package:sqflite/sqflite.dart';

class DoDelDoneTodoTable {
  static const TABLE_NAME = 'DoDelDoneTododb';

  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id INTEGER,
      doTodo INTEGER,
      delTodo INTEGER,
      doneTodo INTEGER
    );   
  ''';
  static const DROP_TABLE_QUERY = '''
      DROP TABLE IF EXISTS $TABLE_NAME
  ''';

  Future<int> insertHabit(DoDelDoneTodo doDelDoneTodo) {
    Database database = DoDelDoneTodoDatabase.instance.database;
    return database.insert(
      TABLE_NAME,
      doDelDoneTodo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDoDelDoneTodo(DoDelDoneTodo doDelDoneTodo) {
    final Database db = DoDelDoneTodoDatabase.instance.database;
    print('update ${doDelDoneTodo.toMap().toString()}');
    return db.update(
      TABLE_NAME,
      doDelDoneTodo.toMap(),
      where: 'id = ?',
      whereArgs: [doDelDoneTodo.id],
    );
  }

  Future<DoDelDoneTodo> selectDoDelDoneTodo() async {
    final Database db = DoDelDoneTodoDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query('$TABLE_NAME');
    if (map.length == 0) {
      await insertHabit(
        DoDelDoneTodo(
          id: 1,
          delTodo: 0,
          doneTodo: 0,
          doTodo: 0,
        ),
      );
      return DoDelDoneTodo(
        id: 1,
        delTodo: 0,
        doneTodo: 0,
        doTodo: 0,
      );
    }
    return DoDelDoneTodo(
      id: 1,
      delTodo: map[0]['delTodo'],
      doneTodo: map[0]['doneTodo'],
      doTodo: map[0]['doTodo'],
    );
  }
}
