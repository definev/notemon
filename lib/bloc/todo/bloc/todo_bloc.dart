import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/todo_database.dart';
import 'package:gottask/database/todo_table.dart';
import 'package:gottask/models/todo.dart';
import 'package:meta/meta.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<Todo> todoList = [];

  @override
  TodoState get initialState => TodoInitial();

  Future<void> _initTodayBloc() async {
    await TodoDatabase.instance.init();
    todoList = await TodoTable.selectAllTodo();
  }

  Future<void> _addEvent(Todo todo) async {
    await TodoTable.insertTodo(todo);
    todoList = await TodoTable.selectAllTodo();
  }

  Future<void> _deleteEvent(Todo todo) async {
    if (todo.audioPath != '') {
      var audioFile = File(todo.audioPath);
      audioFile.deleteSync(recursive: true);
    }
    await TodoTable.deleteTodo(todo.id);
    todoList = await TodoTable.selectAllTodo();
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
      await _deleteEvent(event.todo);
      yield TodoLoaded(todo: todoList);
    } else if (event is EditTodoEvent) {
      await _editEvent(event.todo);
      yield TodoLoaded(todo: todoList);
    }
  }
}
