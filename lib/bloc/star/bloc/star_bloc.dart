import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/repository/firebase_repository.dart';
import 'package:gottask/utils/shared.dart';
import 'package:gottask/utils/utils.dart';
import 'package:meta/meta.dart';

part 'star_event.dart';
part 'star_state.dart';

class StarBloc extends Bloc<StarEvent, StarState> {
  int addStar = 0;
  int loseStar = 0;
  int currentStarPoint = 0;
  FirebaseRepository _repository = FirebaseRepository();
  @override
  StarState get initialState => StarInitial();

  _initStarBloc() async {
    addStar = await getAddStar();
    loseStar = await getLoseStar();
    currentStarPoint = addStar - loseStar;
    await _repository.initUser();
  }

  _addEvent(int point) async {
    addStar += point;
    await setAddStar(addStar);
    currentStarPoint = addStar - loseStar;
    if (await checkConnection()) {
      _repository.updateStarpoint({"addStar": addStar, "loseStar": loseStar});
    }
  }

  _buyEvent(int point) async {
    loseStar += point;
    await setLoseStar(loseStar);
    currentStarPoint = addStar - loseStar;
    if (await checkConnection()) {
      _repository.updateStarpoint({"addStar": addStar, "loseStar": loseStar});
    }
  }

  _setStarEvent(int addStar, int loseStar) async {
    await setAddStar(addStar);
    await setLoseStar(loseStar);
    this.addStar = addStar;
    this.loseStar = loseStar;
    currentStarPoint = addStar - loseStar;
  }

  @override
  Stream<StarState> mapEventToState(
    StarEvent event,
  ) async* {
    if (event is InitStarBloc) {
      await _initStarBloc();
    }
    if (event is SetStarEvent) {
      await _setStarEvent(event.starMap["addStar"], event.starMap["loseStar"]);
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
