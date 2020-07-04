part of 'todo_bloc.dart';

@immutable
abstract class TodoState {}

class TodoInitial extends TodoState {}


class TodoLoaded extends TodoState {
  final List<Todo> todo;

  TodoLoaded({this.todo});
}
