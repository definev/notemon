part of 'all_pokemon_bloc.dart';

@immutable
abstract class AllPokemonState {}

class AllPokemonInitial extends AllPokemonState {}

class AllPokemonLoaded extends AllPokemonState {
  final List<PokemonState> pokemonStateList;

  AllPokemonLoaded(this.pokemonStateList);
}

class AllPokemonWaiting extends AllPokemonState {}
