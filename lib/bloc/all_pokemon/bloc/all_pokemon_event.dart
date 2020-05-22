part of 'all_pokemon_bloc.dart';

@immutable
abstract class AllPokemonEvent {}

class UpdatePokemonStateEvent extends AllPokemonEvent {
  final PokemonState pokemonState;
  UpdatePokemonStateEvent({this.pokemonState});
}

class InitAllPokemonEvent extends AllPokemonEvent {}
