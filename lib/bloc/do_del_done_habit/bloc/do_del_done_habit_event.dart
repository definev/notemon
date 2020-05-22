part of 'do_del_done_habit_bloc.dart';

@immutable
abstract class DoDelDoneHabitEvent {}

class InitDoDelDoneHabitEvent extends DoDelDoneHabitEvent {}

class UpdateDoDelDoneHabitEvent extends DoDelDoneHabitEvent {
  final DoDelDoneHabit habitState;

  UpdateDoDelDoneHabitEvent(this.habitState);
}
