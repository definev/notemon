import 'package:gottask/database/todayTaskDatabase.dart';
import 'package:gottask/models/today_task.dart';
import 'package:sqflite/sqflite.dart';

class TodayTaskTable {
  static const TABLE_NAME = 'todaytaskdb';
  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id INTEGER PRIMARY KEY,
      content TEXT,
      images TEXT,
      isDone INTEGER,
      color INTEGER,
      audioPath TEXT,
      catagories TEXT
    );   
  ''';
  static const DROP_TABLE_QUERY = '''
      DROP TABLE IF EXISTS $TABLE_NAME
  ''';

  Future<int> insertTodo(TodayTask todayTask) {
    final Database db = TodayTaskDatabase.instance.database;
    print('insert ${todayTask.toMap().toString()}');

    return db.insert(
      TABLE_NAME,
      todayTask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTodo(int index) {
    final Database db = TodayTaskDatabase.instance.database;
    print('delete!');
    return db.delete(
      TABLE_NAME,
      where: 'id = ?',
      whereArgs: [index],
    );
  }

  Future<int> updateTodo(TodayTask todayTask) {
    final Database db = TodayTaskDatabase.instance.database;
    print('update checked/edit ${todayTask.toMap().toString()}');
    return db.update(
      TABLE_NAME,
      todayTask.toMap(),
      where: 'id = ?',
      whereArgs: [todayTask.id],
    );
  }

  Future<TodayTask> selectTodo(int index) async {
    final Database db = TodayTaskDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query(
      TABLE_NAME,
      columns: [
        'id',
        'content',
        'images',
        'isDone',
        'color',
        'audioPath',
        'catagories',
      ],
      where: 'id = ?',
      whereArgs: [index],
    );
    return TodayTask(
      id: map[1]['id'],
      content: map[1]['content'],
      images: map[1]['images'],
      isDone: map[1]['isDone'] == 1 ? true : false,
      color: map[1]['color'],
      audioPath: map[1]['audioPath'],
      catagories: map[1]['catagories'],
    );
  }

  Future<List<TodayTask>> selectAllTodo() async {
    final Database db = TodayTaskDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('$TABLE_NAME');
    if (maps.length == 0) return [];
    return List.generate(maps.length, (index) {
      return TodayTask(
        id: maps[index]['id'],
        content: maps[index]['content'],
        images: maps[index]['images'],
        isDone: maps[index]['isDone'] == 1 ? true : false,
        color: maps[index]['color'],
        audioPath: maps[index]['audioPath'],
        catagories: maps[index]['catagories'],
      );
    });
  }
}
