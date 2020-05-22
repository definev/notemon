import 'package:gottask/database/habitDatabase.dart';
import 'package:gottask/models/habit.dart';
import 'package:sqflite/sqflite.dart';

class HabitTable {
  static const TABLE_NAME = 'habitdb';

  static const CREATE_TABLE_QUERY = '''
    CREATE TABLE $TABLE_NAME (
      id INTEGER PRIMARY KEY,
      habitName TEXT,
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
  static const DROP_TABLE_QUERY = '''
      DROP TABLE IF EXISTS $TABLE_NAME
  ''';

  Future<int> insertHabit(Habit habit) {
    Database database = HabitDatabase.instance.database;
    return database.insert(
      TABLE_NAME,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteHabit(Habit habit) {
    Database database = HabitDatabase.instance.database;
    return database.delete(
      TABLE_NAME,
      where: "id = ?",
      whereArgs: [habit.id],
    );
  }

  Future<int> updateHabit(Habit habit) {
    final Database db = HabitDatabase.instance.database;
    print('update ${habit.toMap().toString()}');
    return db.update(
      TABLE_NAME,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<Habit> selectHabit(int index) async {
    final Database db = HabitDatabase.instance.database;
    final List<Map<String, dynamic>> map = await db.query(
      TABLE_NAME,
      columns: [
        'id',
        'icon',
        'habitName',
        'timer',
        'completeTimer',
        'percent',
        'color',
        'achieve',
        'isDoneAchieve',
      ],
      where: 'id = ?',
      whereArgs: [index],
    );
    return Habit(
      id: map[1]['id'],
      habitName: map[1]['habitName'],
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

  Future<List<Habit>> selectAllHabit() async {
    final Database db = HabitDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('$TABLE_NAME');
    if (maps.length == 0) return [];
    return List.generate(maps.length, (index) {
      return Habit(
        id: maps[index]['id'],
        habitName: maps[index]['habitName'],
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
