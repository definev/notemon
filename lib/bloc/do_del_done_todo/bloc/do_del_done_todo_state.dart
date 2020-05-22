part of 'do_del_done_todo_bloc.dart';

@immutable
abstract class DoDelDoneTodoState {}

class DoDelDoneTodoInitial extends DoDelDoneTodoState {}

class DoDelDoneTodoLoaded extends DoDelDoneTodoState {
  final DoDelDoneTodo todoState;

  DoDelDoneTodoLoaded(this.todoState);
}
