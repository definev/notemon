part of 'do_del_done_task_bloc.dart';

abstract class DoDelDoneTaskEvent {}

class InitDoDelDoneTaskEvent extends DoDelDoneTaskEvent {}

class UpdateDoDelDoneTaskEvent extends DoDelDoneTaskEvent {
  final DoDelDoneTask taskState;

  UpdateDoDelDoneTaskEvent(this.taskState);
}
