import 'package:gottask/database/todo_database.dart';
import 'package:gottask/models/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoTable {
  static const TABLE_NAME = 'Tododb';
  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id INTEGER PRIMARY KEY,
      content TEXT,
      images TEXT,
      imageURLs TEXT,
      isDone INTEGER,
      color INTEGER,
      audioPath TEXT,
      catagories TEXT
    );   
  ''';
  static const DROP_TABLE_QUERY = '''
      DROP TABLE IF EXISTS $TABLE_NAME
  ''';

  static Future<int> insertTodo(Todo todo) {
    final Database db = TodoDatabase.instance.database;

    return db.insert(
      TABLE_NAME,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteTodo(int index) {
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
        'imageURLs',
        'isDone',
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
        'content',
        'images',
        'imageURLs',
        'isDone',
        'color',
        'audioPath',
        'catagories',
      ],
      where: 'id = ?',
      whereArgs: [index],
    );
    return Todo(
      id: map[1]['id'],
      content: map[1]['content'],
      images: map[1]['images'],
      imageURLs: map[1]['imageURLs'],
      isDone: map[1]['isDone'] == 1 ? true : false,
      color: map[1]['color'],
      audioPath: map[1]['audioPath'],
      catagories: map[1]['catagories'],
    );
  }

  static Future<List<Todo>> selectAllTodo() async {
    final Database db = TodoDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('$TABLE_NAME');
    if (maps.length == 0) return [];
    return List.generate(maps.length, (index) {
      return Todo(
        id: maps[index]['id'],
        content: maps[index]['content'],
        images: maps[index]['images'],
        imageURLs: maps[index]['imageURLs'],
        isDone: maps[index]['isDone'] == 1 ? true : false,
        color: maps[index]['color'],
        audioPath: maps[index]['audioPath'],
        catagories: maps[index]['catagories'],
      );
    });
  }
}
