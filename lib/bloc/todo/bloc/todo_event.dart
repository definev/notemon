part of 'todo_bloc.dart';

@immutable
abstract class TodoEvent {}

class InitTodoEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final Todo todo;

  AddTodoEvent({this.todo});
}

class DeleteTodoEvent extends TodoEvent {
  final Todo todo;

  DeleteTodoEvent({this.todo});
}

class CheckedTodoEvent extends TodoEvent {
  final Todo todo;

  CheckedTodoEvent({this.todo});
}

class EditTodoEvent extends TodoEvent {
  final Todo todo;

  EditTodoEvent({this.todo});
}
