import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/database/doDelDoneTodoDatabase.dart';
import 'package:gottask/database/doDelDoneTodoTable.dart';
import 'package:gottask/models/do_del_done_task.dart';
import 'package:meta/meta.dart';

part 'do_del_done_todo_event.dart';
part 'do_del_done_todo_state.dart';

class DoDelDoneTodoBloc extends Bloc<DoDelDoneTodoEvent, DoDelDoneTodoState> {
  DoDelDoneTodo todoState;

  @override
  DoDelDoneTodoState get initialState => DoDelDoneTodoInitial();

  Future<void> _initDoDelDoneTodoBloc() async {
    await DoDelDoneTodoDatabase.instance.init();
    todoState = await DoDelDoneTodoTable().selectDoDelDoneTodo();
  }

  Future<void> _updateEvent(DoDelDoneTodo doDelDoneTodo) async {
    await DoDelDoneTodoTable().updateDoDelDoneTodo(doDelDoneTodo);
    todoState = doDelDoneTodo;
  }

  @override
  Stream<DoDelDoneTodoState> mapEventToState(
    DoDelDoneTodoEvent event,
  ) async* {
    if (event is InitDoDelDoneTodoEvent) {
      await _initDoDelDoneTodoBloc();
    }
    if (event is UpdateDoDelDoneTodoEvent) {
      await _updateEvent(event.todoState);
    }
    yield DoDelDoneTodoLoaded(todoState);
  }
}
