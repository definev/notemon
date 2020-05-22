class PokemonState {
  String name;
  int state;
  PokemonState({
    this.name,
    this.state,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state,
    };
  }
}
