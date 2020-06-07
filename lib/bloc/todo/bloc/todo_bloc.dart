import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/todo_database.dart';
import 'package:gottask/database/todo_table.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<Todo> todoList = [];
  List<String> deleteTodoKey = [];

  @override
  TodoState get initialState => TodoInitial();

  Future<void> _initTodayBloc() async {
    await TodoDatabase.instance.init();
    todoList = await TodoTable.selectAllTodo();
    deleteTodoKey = await TodoTable.selectAllDeleteKey();

    print(deleteTodoKey);
  }

  Future<void> _addEvent(Todo todo) async {
    await TodoTable.insertTodo(todo);
    todoList = await TodoTable.selectAllTodo();
  }

  Future<void> _deleteEvent({Todo todo, bool addDeleteKey}) async {
    Directory appDocDirectory;
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    if (todo.audioPath != '') {
      var audioFile = File(appDocDirectory.path + todo.audioPath);
      if (audioFile.existsSync()) audioFile.deleteSync(recursive: true);
    }
    await TodoTable.deleteTodo(todo.id);
    if (addDeleteKey) await TodoTable.insertTodoDeleteKey(todo.id);
    if (await checkConnection()) {
      FirebaseRepository _repository = FirebaseRepository();
      await _repository.initUser();
      if (_repository.user != null) {
        List<String> _onlineKey = await _repository.getDeleteTodoKey();
        for (String key in _onlineKey) {
          if (!deleteTodoKey.contains(key)) {
            TodoTable.insertTodoDeleteKey(key);
          }
        }
      }
    }
    todoList = await TodoTable.selectAllTodo();
    deleteTodoKey = await TodoTable.selectAllDeleteKey();
  }

  Future<void> _editEvent(Todo todo) async {
    await TodoTable.updateTodo(todo);
    todoList = await TodoTable.selectAllTodo();
  }

  @override
  Stream<TodoState> mapEventToState(
    TodoEvent event,
  ) async* {
    if (event is InitTodoEvent) {
      await _initTodayBloc();
      yield TodoLoaded(todo: todoList);
    } else if (event is AddTodoEvent) {
      await _addEvent(event.todo);
      yield TodoLoaded(todo: todoList);
    } else if (event is DeleteTodoEvent) {
      await _deleteEvent(todo: event.todo, addDeleteKey: event.addDeleteKey);
      yield TodoLoaded(todo: todoList);
    } else if (event is EditTodoEvent) {
      await _editEvent(event.todo);
      yield TodoLoaded(todo: todoList);
    }
  }
}
