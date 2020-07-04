part of 'favourite_pokemon_bloc.dart';

@immutable
abstract class FavouritePokemonState {}

class FavouritePokemonInitial extends FavouritePokemonState {}

class FavouritePokemonLoaded extends FavouritePokemonState {
  final int pokemon;

  FavouritePokemonLoaded(this.pokemon);
}
