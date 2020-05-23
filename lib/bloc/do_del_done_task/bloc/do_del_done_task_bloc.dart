import 'dart:async';
import 'package:gottask/database/doDelDoneHabitDatabase.dart';
import 'package:gottask/database/doDelDoneHabitTable.dart';

import 'package:bloc/bloc.dart';
import 'package:gottask/models/do_del_done_task.dart';

part 'do_del_done_task_event.dart';
part 'do_del_done_task_state.dart';

class DoDelDoneTaskBloc extends Bloc<DoDelDoneTaskEvent, DoDelDoneTaskState> {
  DoDelDoneTask taskState;

  @override
  DoDelDoneTaskState get initialState => DoDelDoneTaskInitial();

  Future<void> _initDoDelDoneTaskBloc() async {
    await DoDelDoneTaskDatabase.instance.init();
    taskState = await DoDelDoneTaskTable().selectDoDelDoneTask();
  }

  Future<void> _updateEvent(DoDelDoneTask doDelDoneTask) async {
    await DoDelDoneTaskTable().updateDoDelDoneTask(doDelDoneTask);
    taskState = doDelDoneTask;
  }

  @override
  Stream<DoDelDoneTaskState> mapEventToState(
    DoDelDoneTaskEvent event,
  ) async* {
    if (event is InitDoDelDoneTaskEvent) {
      await _initDoDelDoneTaskBloc();
    }
    if (event is UpdateDoDelDoneTaskEvent) {
      await _updateEvent(event.taskState);
    }
    yield DoDelDoneTaskLoaded(taskState);
  }
}
