part of 'star_bloc.dart';

@immutable
abstract class StarState {}

class StarInitial extends StarState {}

class StarLoaded extends StarState {
  final int currentStar;

  StarLoaded(this.currentStar);
}
