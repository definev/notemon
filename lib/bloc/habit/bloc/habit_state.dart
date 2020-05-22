part of 'habit_bloc.dart';

@immutable
abstract class HabitState {}

class HabitInitial extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habit;

  HabitLoaded(this.habit);
}
