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

  Future<void> _initFavouritePokemonBloc() async =>
      favouritePokemon = await currentFavouritePokemon();

  Future<void> _updateEvent(int newPokemon) async =>
      favouritePokemon = await updateFavouritePokemon(newPokemon);

  @override
  Stream<FavouritePokemonState> mapEventToState(
    FavouritePokemonEvent event,
  ) async* {
    if (event is InitFavouritePokemonEvent) {
      await _initFavouritePokemonBloc();
    }
    if (event is UpdateFavouritePokemonEvent) {
      await _updateEvent(event.newPokemon);
    }
    yield FavouritePokemonLoaded(favouritePokemon);
  }
}
