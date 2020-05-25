class FavouritePokemon {
  int pokemon;

  FavouritePokemon({this.pokemon});

  FavouritePokemon.fromMap(Map<String, dynamic> json) {
    pokemon = json['pokemon'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pokemon'] = this.pokemon;
    return data;
  }
}
