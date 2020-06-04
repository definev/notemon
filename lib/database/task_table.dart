import 'package:gottask/database/task_database.dart';
import 'package:gottask/models/task.dart';
import 'package:sqflite/sqflite.dart';

class TaskTable {
  static const TABLE_NAME = 'Taskdb';
  static const DELETE_TABLE_NAME = 'deleteKeyTaskdb';

  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id TEXT PRIMARY KEY,
      timestamp TEXT,
      TaskName TEXT,
      icon INTEGER,
      color INTEGER,
      catagories TEXT,
      isDoneAchieve TEXT,
      timer TEXT,
      completeTimer TEXT,
      reminder TEXT,
      achieve TEXT,
      percent INTEGER
    );   
  ''';
  static const CREATE_DELETE_TABLE_QUERY = '''
    CREATE TABLE $DELETE_TABLE_NAME (id TEXT PRIMARY KEY);  
  ''';

  /// [Task delete key]
  static Future<int> insertTaskDeleteKey(String id) {
    final Database db = TaskDatabase.instance.database;

    return db.insert(
      DELETE_TABLE_NAME,
      {'id': id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<String>> selectAllDeleteKey() async {
    final Database db = TaskDatabase.instance.database;

    final deleteKeyList = await db.query(DELETE_TABLE_NAME);
    List<String> deleteKey = [];
    deleteKeyList.forEach((map) => deleteKey.add(map['id']));
    return deleteKey;
  }

  static Future<void> deleteAllDeleteKey() async {
    final Database db = TaskDatabase.instance.database;
    List<String> deleteKey = await selectAllDeleteKey();
    deleteKey.forEach((key) async {
      await db.delete(
        DELETE_TABLE_NAME,
        where: 'id = ?',
        whereArgs: [key],
      );
    });
  }

  ///[Task] databases
  static Future<int> insertTask(Task task) {
    final Database database = TaskDatabase.instance.database;

    return database.insert(
      TABLE_NAME,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteTask(Task task) {
    final Database database = TaskDatabase.instance.database;
    return database.delete(
      TABLE_NAME,
      where: "id = ?",
      whereArgs: [task.id],
    );
  }

  static Future<int> updateTask(Task task) {
    final Database db = TaskDatabase.instance.database;
    return db.update(
      TABLE_NAME,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<Task> selectTask(String id) async {
    final Database db = TaskDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query(
      TABLE_NAME,
      columns: [
        'id',
        'icon',
        'TaskName',
        'timer',
        'completeTimer',
        'percent',
        'color',
        'achieve',
        'isDoneAchieve',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );
    return Task(
      id: map[1]['id'],
      timestamp: DateTime.parse(map[1]['timestamp']),
      taskName: map[1]['TaskName'],
      color: map[1]['color'],
      icon: map[1]['icon'],
      catagories: map[1]['catagories'],
      achieve: map[1]['achieve'],
      timer: map[1]['timer'],
      completeTimer: map[1]['completeTimer'],
      percent: map[1]['percent'],
      isDoneAchieve: map[1]['isDoneAchieve'],
    );
  }

  static Future<List<Task>> selectAllTask() async {
    final Database db = TaskDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('$TABLE_NAME');
    if (maps.length == 0) return [];
    return List.generate(maps.length, (index) {
      return Task(
        id: maps[index]['id'],
        timestamp: DateTime.parse(maps[index]['timestamp']),
        taskName: maps[index]['TaskName'],
        color: maps[index]['color'],
        catagories: maps[index]['catagories'],
        icon: maps[index]['icon'],
        achieve: maps[index]['achieve'],
        timer: maps[index]['timer'],
        completeTimer: maps[index]['completeTimer'],
        percent: maps[index]['percent'],
        isDoneAchieve: maps[index]['isDoneAchieve'],
      );
    });
  }
}
