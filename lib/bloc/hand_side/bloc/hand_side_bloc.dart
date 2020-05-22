import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/utils/utils.dart' as utils;
import 'package:meta/meta.dart';

part 'hand_side_event.dart';
part 'hand_side_state.dart';

class HandSideBloc extends Bloc<HandSideEvent, HandSideState> {
  utils.HandSide currentHandSide;

  @override
  HandSideState get initialState => HandSideInitial();

  Future<void> _changeHandSide(utils.HandSide handSide) async {
    await utils.updateHandSide(handSide);
    currentHandSide = handSide;
  }

  Future<void> _initHandSide() async {
    
    currentHandSide = await utils.currentHandSide();
  }

  @override
  Stream<HandSideState> mapEventToState(
    HandSideEvent event,
  ) async* {
    if (event is HandSideChanged) {
      await _changeHandSide(event.handSide);
    } else {
      await _initHandSide();
    }
    yield HandSideLoaded(currentHandSide);
  }
}
