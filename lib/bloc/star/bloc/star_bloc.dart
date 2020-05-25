import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/repository/firebase_repository.dart';
import 'package:gottask/utils/shared.dart';
import 'package:gottask/utils/utils.dart';
import 'package:meta/meta.dart';

part 'star_event.dart';
part 'star_state.dart';

class StarBloc extends Bloc<StarEvent, StarState> {
  int currentStarPoint = 0;
  FirebaseRepository _repository = FirebaseRepository();
  @override
  StarState get initialState => StarInitial();

  _initStarBloc() async {
    currentStarPoint = await currentStar();
  }

  _addEvent(int point) async {
    await getStar(point);
    currentStarPoint += point;
    if (await checkConnection()) {
      _repository.updateStarpoint(currentStarPoint);
    }
  }

  _buyEvent(int cost) async {
    await loseStar(cost);
    currentStarPoint -= cost;
    if (await checkConnection()) {
      _repository.updateStarpoint(currentStarPoint);
    }
  }

  _setStarEvent(int star) async {
    await setStar(star);
    currentStarPoint = star;
  }

  @override
  Stream<StarState> mapEventToState(
    StarEvent event,
  ) async* {
    if (event is InitStarBloc) {
      await _initStarBloc();
    }
    if (event is SetStarEvent) {
      await _setStarEvent(event.point);
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
