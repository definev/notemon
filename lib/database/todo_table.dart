import 'package:gottask/database/todo_database.dart';
import 'package:gottask/models/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoTable {
  static const TABLE_NAME = 'Tododb';
  static const DELETE_TABLE_NAME = 'deleteKeyTododb';
  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id TEXT PRIMARY KEY,
      timestamp TEXT,
      content TEXT,
      images TEXT,
      state TEXT,
      color INTEGER,
      audioPath TEXT,
      audioCode TEXT,
      catagories TEXT
    );   
  ''';
  static const CREATE_DELETE_TABLE_QUERY = '''
    CREATE TABLE $DELETE_TABLE_NAME (id TEXT PRIMARY KEY);  
  ''';

  /// [Todo delete key]
  static Future<int> insertTodoDeleteKey(String id) {
    final Database db = TodoDatabase.instance.database;

    return db.insert(
      DELETE_TABLE_NAME,
      {'id': id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<String>> selectAllDeleteKey() async {
    final Database db = TodoDatabase.instance.database;

    final deleteKeyList = await db.query(DELETE_TABLE_NAME);
    List<String> deleteKey = [];
    deleteKeyList.forEach((map) => deleteKey.add(map['id']));
    return deleteKey;
  }

  static Future<void> deleteAllDeleteKey() async {
    final Database db = TodoDatabase.instance.database;
    List<String> deleteKey = await selectAllDeleteKey();
    deleteKey.forEach((key) async {
      await db.delete(
        DELETE_TABLE_NAME,
        where: 'id = ?',
        whereArgs: [key],
      );
    });
  }

  /// [Todo] database
  static Future<int> insertTodo(Todo todo) {
    final Database db = TodoDatabase.instance.database;

    return db.insert(
      TABLE_NAME,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteTodo(String index) {
    final Database db = TodoDatabase.instance.database;
    print('delete!');
    return db.delete(
      TABLE_NAME,
      where: 'id = ?',
      whereArgs: [index],
    );
  }

  static Future<int> updateTodo(Todo todo) {
    final Database db = TodoDatabase.instance.database;
    return db.update(
      TABLE_NAME,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  static Future<int> updateOrInsertNewTodo(Todo todo) async {
    final Database db = TodoDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query(
      TABLE_NAME,
      columns: [
        'id',
        'content',
        'images',
        'state',
        'color',
        'audioPath',
        'catagories',
      ],
      where: 'id = ?',
      whereArgs: [todo.id],
    );
    if (map.isNotEmpty) {
      return updateTodo(todo);
    } else {
      return insertTodo(todo);
    }
  }

  static Future<Todo> selectTodo(int index) async {
    final Database db = TodoDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query(
      TABLE_NAME,
      columns: [
        'id',
        'timestamp',
        'content',
        'images',
        'state',
        'color',
        'audioPath',
        'audioCode',
        'catagories',
      ],
      where: 'id = ?',
      whereArgs: [index],
    );
    List<String> _rawCatagoryItems = map[1]['catagories']
        .substring(1, map[1]['catagories'].length - 1)
        .split(', ');
    List<bool> _catagoriesItems = _rawCatagoryItems
        .map((isCheck) => isCheck == 'false' ? false : true)
        .toList();
    return Todo(
      id: map[1]['id'],
      timestamp: DateTime.parse(map[1]['timestamp']),
      content: map[1]['content'],
      images: map[1]['images'],
      state: map[1]['state'],
      color: map[1]['color'],
      audioPath: map[1]['audioPath'],
      audioCode: map[1]['audioCode'],
      catagories: _catagoriesItems,
    );
  }

  static Future<List<Todo>> selectAllTodo() async {
    final Database db = TodoDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
    if (maps.length == 0) return [];
    return List.generate(maps.length, (index) {
      List<String> _rawCatagoryItems = maps[index]['catagories']
          .substring(1, maps[index]['catagories'].length - 1)
          .split(', ');
      List<bool> _catagoriesItems = _rawCatagoryItems
          .map((isCheck) => isCheck == 'false' ? false : true)
          .toList();
      return Todo(
        id: maps[index]['id'],
        timestamp: DateTime.parse(maps[index]['timestamp']),
        content: maps[index]['content'],
        images: maps[index]['images'],
        state: maps[index]['state'],
        color: maps[index]['color'],
        audioPath: maps[index]['audioPath'],
        audioCode: maps[index]['audioCode'],
        catagories: _catagoriesItems,
      );
    });
  }
}
