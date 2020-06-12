import 'dart:io';

import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/utils/utils.dart';

extension PokemonExt on List<PokemonState> {
  String collectedPokemon() {
    int collected = 0;
    int total = pokedex.length;
    if (this != null) {
      this.forEach((element) {
        if (element.state == 1) collected++;
      });
      return "$collected / $total";
    } else {
      return "0 / 50";
    }
  }
}

extension FileName on File {
  String get name => path.split('/').last;
}

