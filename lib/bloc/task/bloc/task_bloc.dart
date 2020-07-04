import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/task_database.dart';
import 'package:gottask/database/task_table.dart';
import 'package:gottask/models/task.dart';
import 'package:meta/meta.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  List<Task> taskList = [];
  List<String> deleteTaskKey = [];

  @override
  TaskState get initialState => TaskInitial();

  Future<void> _initTaskBloc() async {
    await TaskDatabase.instance.init();
    taskList = await TaskTable.selectAllTask();
    deleteTaskKey = await TaskTable.selectAllDeleteKey();
  }

  Future<void> _addEvent(Task task) async {
    await TaskTable.insertTask(task);
    bool isAdd = !taskList.contains(task);
    if (isAdd) {
      taskList.add(task);
    }
  }

  Future<void> _updateEvent(Task task) async {
    await TaskTable.updateTask(task);
    taskList[taskList.indexWhere((currentTask) => currentTask == task)] = task;
  }

  Future<void> _deleteEvent(Task task, bool addDeleteKey) async {
    await TaskTable.deleteTask(task);
    taskList
        .removeAt(taskList.indexWhere((currentTask) => currentTask == task));
    if (addDeleteKey) {
      await TaskTable.insertTaskDeleteKey(task.id);
      print((await TaskTable.selectAllTask()).toString());
      deleteTaskKey = await TaskTable.selectAllDeleteKey();
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
    if (event is EditTaskEvent) {
      await _updateEvent(event.task);
    }
    if (event is DeleteTaskEvent) {
      await _deleteEvent(event.task, event.addDeleteKey);
    }
    yield TaskLoaded(taskList);
  }
}
