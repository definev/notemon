part of 'habit_bloc.dart';

@immutable
abstract class HabitEvent {}

class InitHabitEvent extends HabitEvent {}

class AddHabitEvent extends HabitEvent {
  final Habit habit;

  AddHabitEvent(this.habit);
}

class UpdateHabitEvent extends HabitEvent {
  final Habit habit;

  UpdateHabitEvent(this.habit);
}

class DeleteHabitEvent extends HabitEvent {
  final Habit habit;

  DeleteHabitEvent(this.habit);
}
