part of 'task_bloc.dart';

@immutable
abstract class TaskEvent {}

class InitTaskEvent extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final Task task;

  AddTaskEvent({this.task});
}

class EditTaskEvent extends TaskEvent {
  final Task task;

  EditTaskEvent({this.task});
}

class DeleteTaskEvent extends TaskEvent {
  final Task task;
  final bool addDeleteKey;
  DeleteTaskEvent({this.task, @required this.addDeleteKey});
}
