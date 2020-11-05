// To parse this JSON data, do
//
//     final store = storeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Store {
  Store({
    @required this.trivial,
    @required this.rare,
    @required this.superrare,
  });

  final List<String> trivial;
  final List<String> rare;
  final List<String> superrare;

  Store copyWith({
    List<String> trivial,
    List<String> rare,
    List<String> superrare,
  }) =>
      Store(
        trivial: trivial ?? this.trivial,
        rare: rare ?? this.rare,
        superrare: superrare ?? this.superrare,
      );

  factory Store.fromRawJson(String str) => Store.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        trivial: List<String>.from(json["trivial"].map((x) => x)),
        rare: List<String>.from(json["rare"].map((x) => x)),
        superrare: List<String>.from(json["superrare"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "trivial": List<dynamic>.from(trivial.map((x) => x)),
        "rare": List<dynamic>.from(rare.map((x) => x)),
        "superrare": List<dynamic>.from(superrare.map((x) => x)),
      };
}
