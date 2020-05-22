import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/utils/shared.dart';
import 'package:meta/meta.dart';

part 'star_event.dart';
part 'star_state.dart';

class StarBloc extends Bloc<StarEvent, StarState> {
  int currentStarPoint = 0;
  @override
  StarState get initialState => StarInitial();

  _initStarBloc() async {
    currentStarPoint = await currentStar();
  }

  _addEvent(int point) async {
    await getStar(point);
    currentStarPoint += point;
  }

  _buyEvent(int cost) async {
    await loseStar(cost);
    currentStarPoint -= cost;
  }

  @override
  Stream<StarState> mapEventToState(
    StarEvent event,
  ) async* {
    if (event is InitStarBloc) {
      await _initStarBloc();
    }
    if (event is AddStarEvent) {
      await _addEvent(event.point);
    }
    if (event is BuyItemEvent) {
      await _buyEvent(event.point);
    }
    yield StarLoaded(currentStarPoint);
  }
}
