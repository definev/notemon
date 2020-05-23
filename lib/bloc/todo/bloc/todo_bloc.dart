import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/todayTaskDatabase.dart';
import 'package:gottask/database/todayTaskTable.dart';
import 'package:gottask/models/today_task.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:meta/meta.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<TodayTask> todoList = [];
  FirebaseRepository _repository = FirebaseRepository();

  @override
  TodoState get initialState => TodoInitial();

  Future<void> _initTodayBloc() async {
    await TodayTaskDatabase.instance.init();
    todoList = await TodayTaskTable.selectAllTodo();
    checkConnection(
        () async => await _repository.uploadAllTodoToFirebase(todoList));
  }

  Future<void> _addEvent(TodayTask todayTask) async {
    await TodayTaskTable.insertTodo(todayTask);
    todoList = await TodayTaskTable.selectAllTodo();
    checkConnection(
        () async => await _repository.updateTodoToFirebase(todayTask));
  }

  Future<void> _deleteEvent(TodayTask todayTask) async {
    List<String> imageLinks =
        todayTask.images.substring(1, todayTask.images.length - 1).split(', ');
    if (imageLinks[0] != '') {
      imageLinks.forEach((path) {
        var dir = File(path);
        dir.deleteSync(recursive: true);
      });
    }
    if (todayTask.audioPath != '') {
      var audioFile = File(todayTask.audioPath);
      audioFile.deleteSync(recursive: true);
    }
    await TodayTaskTable.deleteTodo(todayTask.id);
    todoList = await TodayTaskTable.selectAllTodo();
    checkConnection(
        () async => await _repository.updateTodoToFirebase(todayTask));
  }

  Future<void> _editEvent(TodayTask todayTask) async {
    await TodayTaskTable.updateTodo(todayTask);
    todoList = await TodayTaskTable.selectAllTodo();
    checkConnection(
        () async => await _repository.updateTodoToFirebase(todayTask));
  }

  @override
  Stream<TodoState> mapEventToState(
    TodoEvent event,
  ) async* {
    if (event is InitTodoEvent) {
      await _initTodayBloc();
      yield TodoLoaded(todo: todoList);
    } else if (event is AddTodayTaskEvent) {
      await _addEvent(event.todayTask);
      yield TodoLoaded(todo: todoList);
    } else if (event is DeleteTodayTaskEvent) {
      await _deleteEvent(event.todayTask);
      yield TodoLoaded(todo: todoList);
    } else if (event is EditTodayTaskEvent) {
      await _editEvent(event.todayTask);
      yield TodoLoaded(todo: todoList);
    }
  }
}
