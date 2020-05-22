import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gottask/database/pokemonStateDatabase.dart';
import 'package:gottask/database/pokemonStateTable.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:meta/meta.dart';

part 'all_pokemon_event.dart';
part 'all_pokemon_state.dart';

class AllPokemonBloc extends Bloc<AllPokemonEvent, AllPokemonState> {
  List<PokemonState> allPokemonStateList;
  @override
  AllPokemonState get initialState => AllPokemonInitial();

  Future<void> _initAllPokemonBloc() async {
    allPokemonStateList = await PokemonStateDatabase.instance.init();
    allPokemonStateList = await PokemonStateTable.selectAllPokemonState();
  }

  Future<void> _updateEvent(PokemonState pokemonState) async {
    await PokemonStateTable.updatePokemonState(pokemonState);
    allPokemonStateList = await PokemonStateTable.selectAllPokemonState();
  }

  @override
  Stream<AllPokemonState> mapEventToState(
    AllPokemonEvent event,
  ) async* {
    if (event is UpdatePokemonStateEvent) {
      await _updateEvent(event.pokemonState);
    } else if (event is InitAllPokemonEvent) {
      await _initAllPokemonBloc();
    }
    yield AllPokemonLoaded(allPokemonStateList);
  }
}
