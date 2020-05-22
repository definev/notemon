import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/habitDatabase.dart';
import 'package:gottask/database/habitTable.dart';
import 'package:gottask/models/habit.dart';
import 'package:meta/meta.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  List<Habit> habitList = [];

  @override
  HabitState get initialState => HabitInitial();

  Future<void> _initHabitBloc() async {
    await HabitDatabase.instance.init();
    habitList = await HabitTable().selectAllHabit();
  }

  Future<void> _addEvent(Habit habit) async {
    habitList.add(habit);
    await HabitTable().insertHabit(habit);
    print('add: ${habit.toMap().toString()}');
  }

  Future<void> _updateEvent(Habit habit) async {
    await HabitTable().updateHabit(habit);
    habitList = await HabitTable().selectAllHabit();
  }

  Future<void> _deleteEvent(Habit habit) async {
    await HabitTable().deleteHabit(habit);
    habitList = await HabitTable().selectAllHabit();
  }

  @override
  Stream<HabitState> mapEventToState(
    HabitEvent event,
  ) async* {
    if (event is InitHabitEvent) {
      await _initHabitBloc();
    }
    if (event is AddHabitEvent) {
      _addEvent(event.habit);
    }
    if (event is UpdateHabitEvent) {
      _updateEvent(event.habit);
    }
    if (event is DeleteHabitEvent) {
      _deleteEvent(event.habit);
    }
    yield HabitLoaded(habitList);
  }
}
