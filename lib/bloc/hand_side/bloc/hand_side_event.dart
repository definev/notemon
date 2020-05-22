part of 'hand_side_bloc.dart';

@immutable
abstract class HandSideEvent {}

class InitHandSide extends HandSideEvent {}

class HandSideChanged extends HandSideEvent {
  final utils.HandSide handSide;

  HandSideChanged({this.handSide});
}
