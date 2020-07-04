part of 'task_bloc.dart';

@immutable
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> task;

  TaskLoaded(this.task);
}
