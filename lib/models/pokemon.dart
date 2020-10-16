// To parse this JSON data, do
//
//     final pokemon = pokemonFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Pokemon {
  Pokemon({
    @required this.name,
    @required this.imageUrl,
    @required this.hp,
    @required this.attack,
    @required this.defense,
    @required this.speed,
    @required this.spAtk,
    @required this.spDef,
    @required this.height,
    @required this.weight,
    @required this.category,
    @required this.type,
    @required this.weaknesses,
    @required this.introduction,
  });

  final String name;
  final String imageUrl;
  final String hp;
  final String attack;
  final String defense;
  final String speed;
  final String spAtk;
  final String spDef;
  final String height;
  final String weight;
  final String category;
  final Type type;
  final Type weaknesses;
  final Introduction introduction;

  Pokemon copyWith({
    String name,
    String imageUrl,
    String hp,
    String attack,
    String defense,
    String speed,
    String spAtk,
    String spDef,
    String height,
    String weight,
    String category,
    Type type,
    Type weaknesses,
    Introduction introduction,
  }) =>
      Pokemon(
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        hp: hp ?? this.hp,
        attack: attack ?? this.attack,
        defense: defense ?? this.defense,
        speed: speed ?? this.speed,
        spAtk: spAtk ?? this.spAtk,
        spDef: spDef ?? this.spDef,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        category: category ?? this.category,
        type: type ?? this.type,
        weaknesses: weaknesses ?? this.weaknesses,
        introduction: introduction ?? this.introduction,
      );

  factory Pokemon.fromRawJson(String str) => Pokemon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        name: json["name"],
        imageUrl: json["imageURL"],
        hp: json["HP"],
        attack: json["Attack"],
        defense: json["Defense"],
        speed: json["speed"],
        spAtk: json["spAtk"],
        spDef: json["spDef"],
        height: json["height"],
        weight: json["weight"],
        category: json["category"],
        type: Type.fromJson(json["type"]),
        weaknesses: Type.fromJson(json["weaknesses"]),
        introduction: Introduction.fromJson(json["introduction"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "imageURL": imageUrl,
        "HP": hp,
        "Attack": attack,
        "Defense": defense,
        "speed": speed,
        "spAtk": spAtk,
        "spDef": spDef,
        "height": height,
        "weight": weight,
        "category": category,
        "type": type.toJson(),
        "weaknesses": weaknesses.toJson(),
        "introduction": introduction.toJson(),
      };

  int getInfoByType(String type) {
    switch (type) {
      case "HP":
        return int.parse(hp);
      case "Attack":
        return int.parse(attack);
      case "Defense":
        return int.parse(defense);
      case "speed":
        return int.parse(speed);
      case "spAtk":
        return int.parse(spAtk);
      default:
        return int.parse(spDef);
    }
  }
}

class Introduction {
  Introduction({
    @required this.en,
    @required this.vi,
  });

  final String en;
  final String vi;

  Introduction copyWith({
    String en,
    String vi,
  }) =>
      Introduction(
        en: en ?? this.en,
        vi: vi ?? this.vi,
      );

  factory Introduction.fromRawJson(String str) =>
      Introduction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Introduction.fromJson(Map<String, dynamic> json) => Introduction(
        en: json["en"],
        vi: json["vi"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
        "vi": vi,
      };
}

class Type {
  Type({
    @required this.en,
    @required this.vi,
  });

  final List<String> en;
  final List<String> vi;

  Type copyWith({
    List<String> en,
    List<String> vi,
  }) =>
      Type(
        en: en ?? this.en,
        vi: vi ?? this.vi,
      );

  factory Type.fromRawJson(String str) => Type.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        en: List<String>.from(json["en"].map((x) => x)),
        vi: List<String>.from(json["vi"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "en": List<dynamic>.from(en.map((x) => x)),
        "vi": List<dynamic>.from(vi.map((x) => x)),
      };
}
