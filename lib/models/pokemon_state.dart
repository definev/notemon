class PokemonState {
  String name;
  int state;

  PokemonState({this.name, this.state});

  PokemonState.fromMap(Map<String, dynamic> json) {
    name = json['name'];
    state = json['state'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['state'] = this.state;
    return data;
  }
}
