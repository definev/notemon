part of 'star_bloc.dart';

@immutable
abstract class StarEvent {}

class InitStarBloc extends StarEvent {}

class SetStarEvent extends StarEvent {
  final Map<String, int> starMap;
  SetStarEvent({this.starMap});
}

class AddStarEvent extends StarEvent {
  final int point;
  AddStarEvent({this.point});
}

class BuyItemEvent extends StarEvent {
  final int point;
  BuyItemEvent({this.point});
}
