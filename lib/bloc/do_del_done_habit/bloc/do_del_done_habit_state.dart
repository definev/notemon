part of 'do_del_done_habit_bloc.dart';

@immutable
abstract class DoDelDoneHabitState {}

class DoDelDoneHabitInitial extends DoDelDoneHabitState {}

class DoDelDoneHabitLoaded extends DoDelDoneHabitState {
  final DoDelDoneHabit habitState;

  DoDelDoneHabitLoaded(this.habitState);
}
