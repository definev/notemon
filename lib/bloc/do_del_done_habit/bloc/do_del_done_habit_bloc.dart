import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/doDelDoneHabitDatabase.dart';
import 'package:gottask/database/doDelDoneHabitTable.dart';
import 'package:gottask/models/do_del_done_habit.dart';
import 'package:meta/meta.dart';

part 'do_del_done_habit_event.dart';
part 'do_del_done_habit_state.dart';

class DoDelDoneHabitBloc
    extends Bloc<DoDelDoneHabitEvent, DoDelDoneHabitState> {
  DoDelDoneHabit habitState;

  @override
  DoDelDoneHabitState get initialState => DoDelDoneHabitInitial();

  Future<void> _initDoDelDoneHabitBloc() async {
    await DoDelDoneHabitDatabase.instance.init();
    habitState = await DoDelDoneHabitTable().selectDoDelDoneHabit();
  }

  Future<void> _updateEvent(DoDelDoneHabit doDelDoneHabit) async {
    await DoDelDoneHabitTable().updateDoDelDoneHabit(doDelDoneHabit);
    habitState = doDelDoneHabit;
  }

  @override
  Stream<DoDelDoneHabitState> mapEventToState(
    DoDelDoneHabitEvent event,
  ) async* {
    if (event is InitDoDelDoneHabitEvent) {
      await _initDoDelDoneHabitBloc();
    }
    if (event is UpdateDoDelDoneHabitEvent) {
      await _updateEvent(event.habitState);
    }
    yield DoDelDoneHabitLoaded(habitState);
  }
}
