import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/task_database.dart';
import 'package:gottask/database/task_table.dart';
import 'package:gottask/models/habit.dart';
import 'package:gottask/repository/firebase_repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:meta/meta.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  List<Task> taskList = [];
  FirebaseRepository _repository = FirebaseRepository();

  @override
  TaskState get initialState => TaskInitial();

  Future<void> _initTaskBloc() async {
    await TaskDatabase.instance.init();
    taskList = await TaskTable.selectAllTask();
    if (await checkConnection() == true) {
      await _repository.uploadAllTaskToFirebase(taskList);
    }
  }

  Future<void> _addEvent(Task task) async {
    await TaskTable.insertTask(task);
    taskList = await TaskTable.selectAllTask();
    if (await checkConnection() == true) {
      await _repository.updateTaskToFirebase(task);
    }
  }

  Future<void> _updateEvent(Task task) async {
    await TaskTable.updateTask(task);
    taskList = await TaskTable.selectAllTask();
    if (await checkConnection() == true) {
      await _repository.updateTaskToFirebase(task);
    }
  }

  Future<void> _deleteEvent(Task task) async {
    await TaskTable.deleteTask(task);
    taskList = await TaskTable.selectAllTask();
    if (await checkConnection() == true) {
      await _repository.deleteTaskOnFirebase(task);
    }
  }

  @override
  Stream<TaskState> mapEventToState(
    TaskEvent event,
  ) async* {
    if (event is InitTaskEvent) {
      await _initTaskBloc();
    }
    if (event is AddTaskEvent) {
      await _addEvent(event.task);
    }
    if (event is UpdateTaskEvent) {
      await _updateEvent(event.task);
    }
    if (event is DeleteTaskEvent) {
      await _deleteEvent(event.task);
    }
    yield TaskLoaded(taskList);
  }
}
