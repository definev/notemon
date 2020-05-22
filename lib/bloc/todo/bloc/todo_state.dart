part of 'todo_bloc.dart';

@immutable
abstract class TodoState {}

class TodoInitial extends TodoState {}


class TodoLoaded extends TodoState {
  final List<TodayTask> todo;

  TodoLoaded({this.todo});
}
