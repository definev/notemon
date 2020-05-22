part of 'todo_bloc.dart';

@immutable
abstract class TodoEvent {}

class InitTodoEvent extends TodoEvent {}

class AddTodayTaskEvent extends TodoEvent {
  final TodayTask todayTask;

  AddTodayTaskEvent({this.todayTask});
}

class DeleteTodayTaskEvent extends TodoEvent {
  final TodayTask todayTask;

  DeleteTodayTaskEvent({this.todayTask});
}

class CheckedTodayTaskEvent extends TodoEvent {
  final TodayTask todayTask;

  CheckedTodayTaskEvent({this.todayTask});
}

class EditTodayTaskEvent extends TodoEvent {
  final TodayTask todayTask;

  EditTodayTaskEvent({this.todayTask});
}
