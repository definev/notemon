part of 'hand_side_bloc.dart';

@immutable
abstract class HandSideState {}

class HandSideInitial extends HandSideState {}

class HandSideLoaded extends HandSideState {
  final utils.HandSide handSide;

  HandSideLoaded(this.handSide);
}
