part of 'do_del_done_todo_bloc.dart';

@immutable
abstract class DoDelDoneTodoEvent {}

class InitDoDelDoneTodoEvent extends DoDelDoneTodoEvent {}

class UpdateDoDelDoneTodoEvent extends DoDelDoneTodoEvent {
  final DoDelDoneTodo todoState;

  UpdateDoDelDoneTodoEvent(this.todoState);
}
