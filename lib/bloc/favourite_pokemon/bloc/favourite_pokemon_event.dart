part of 'favourite_pokemon_bloc.dart';

@immutable
abstract class FavouritePokemonEvent {}

class InitFavouritePokemonEvent extends FavouritePokemonEvent {}

class UpdateFavouritePokemonEvent extends FavouritePokemonEvent {
  final int newPokemon;

  UpdateFavouritePokemonEvent(this.newPokemon);
}
