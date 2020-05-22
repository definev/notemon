import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gottask/utils/shared.dart';
import 'package:meta/meta.dart';

part 'favourite_pokemon_event.dart';
part 'favourite_pokemon_state.dart';

class FavouritePokemonBloc
    extends Bloc<FavouritePokemonEvent, FavouritePokemonState> {
  int favouritePokemon = -1;
  @override
  FavouritePokemonState get initialState => FavouritePokemonInitial();

  Future<int> _initFavouritePokemonBloc() async {
    favouritePokemon = await currentFavouritePokemon();
    return favouritePokemon;
  }

  Future<int> _updateEvent(int newPokemon) async {
    favouritePokemon = await updateFavouritePokemon(newPokemon);
    return favouritePokemon;
  }

  @override
  Stream<FavouritePokemonState> mapEventToState(
    FavouritePokemonEvent event,
  ) async* {
    if (event is InitFavouritePokemonEvent) {
      int pokemon = await _initFavouritePokemonBloc();
      yield FavouritePokemonLoaded(pokemon);
    }
    if (event is UpdateFavouritePokemonEvent) {
      _updateEvent(event.newPokemon);
      yield FavouritePokemonLoaded(event.newPokemon);
    }
  }
}
