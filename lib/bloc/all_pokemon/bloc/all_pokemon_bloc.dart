import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gottask/database/pokemonStateDatabase.dart';
import 'package:gottask/database/pokemonStateTable.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/repository/repository.dart';
import 'package:meta/meta.dart';

part 'all_pokemon_event.dart';
part 'all_pokemon_state.dart';

class AllPokemonBloc extends Bloc<AllPokemonEvent, AllPokemonState> {
  List<PokemonState> pokemonStateList;
  FirebaseRepository _repository = FirebaseRepository();

  @override
  AllPokemonState get initialState => AllPokemonInitial();

  Future<void> _initAllPokemonBloc() async {
    await PokemonStateDatabase.instance.init();
    pokemonStateList = await PokemonStateTable.selectAllPokemonState();
    _repository.uploadAllPokemonStateToFirebase(pokemonStateList);
  }

  Future<void> _updateEvent(PokemonState pokemonState) async {
    await PokemonStateTable.updatePokemonState(pokemonState);
    pokemonStateList = await PokemonStateTable.selectAllPokemonState();
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
    yield AllPokemonLoaded(pokemonStateList);
  }
}