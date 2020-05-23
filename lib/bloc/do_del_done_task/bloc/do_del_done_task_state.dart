part of 'do_del_done_task_bloc.dart';

abstract class DoDelDoneTaskState {}

class DoDelDoneTaskInitial extends DoDelDoneTaskState {}

class DoDelDoneTaskLoaded extends DoDelDoneTaskState {
  final DoDelDoneTask taskState;

  DoDelDoneTaskLoaded(this.taskState);
}
