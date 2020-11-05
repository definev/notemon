import 'dart:convert';
import 'package:meta/meta.dart';

class RarityQuantity {
  RarityQuantity({
    @required this.trivial,
    @required this.rare,
    @required this.superrare,
  });

  final int trivial;
  final int rare;
  final int superrare;

  RarityQuantity copyWith({
    int trivial,
    int rare,
    int superrare,
  }) =>
      RarityQuantity(
        trivial: trivial ?? this.trivial,
        rare: rare ?? this.rare,
        superrare: superrare ?? this.superrare,
      );

  factory RarityQuantity.fromRawJson(String str) =>
      RarityQuantity.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RarityQuantity.fromJson(Map<String, dynamic> json) => RarityQuantity(
        trivial: json["trivial"],
        rare: json["rare"],
        superrare: json["superrare"],
      );

  Map<String, dynamic> toJson() => {
        "trivial": trivial,
        "rare": rare,
        "superrare": superrare,
      };
}

class QuantityMapSpriteStore {
  QuantityMapSpriteStore({
    this.body,
    this.skin,
    this.hair,
    this.hairTail,
    this.eye,
    this.beard,
    this.ear,
    this.hat,
    this.glasses,
    this.cloak,
    this.tail,
    this.item,
  });

  final RarityQuantity body;
  final RarityQuantity skin;
  final RarityQuantity hair;
  final RarityQuantity hairTail;
  final RarityQuantity eye;
  final RarityQuantity beard;
  final RarityQuantity ear;
  final RarityQuantity hat;
  final RarityQuantity glasses;
  final RarityQuantity cloak;
  final RarityQuantity tail;
  final RarityQuantity item;

  QuantityMapSpriteStore copyWith({
    RarityQuantity body,
    RarityQuantity skin,
    RarityQuantity hair,
    RarityQuantity hairTail,
    RarityQuantity eye,
    RarityQuantity beard,
    RarityQuantity ear,
    RarityQuantity hat,
    RarityQuantity glasses,
    RarityQuantity cloak,
    RarityQuantity tail,
    RarityQuantity item,
  }) =>
      QuantityMapSpriteStore(
        body: body ?? this.body,
        skin: skin ?? this.skin,
        hair: hair ?? this.hair,
        hairTail: hairTail ?? this.hairTail,
        eye: eye ?? this.eye,
        beard: beard ?? this.beard,
        ear: ear ?? this.ear,
        hat: hat ?? this.hat,
        glasses: glasses ?? this.glasses,
        cloak: cloak ?? this.cloak,
        tail: tail ?? this.tail,
        item: item ?? this.item,
      );

  factory QuantityMapSpriteStore.fromRawJson(String str) =>
      QuantityMapSpriteStore.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuantityMapSpriteStore.fromJson(Map<String, dynamic> json) =>
      QuantityMapSpriteStore(
        body: RarityQuantity.fromJson(json["Body"]),
        skin: RarityQuantity.fromJson(json["Skin"]),
        hair: RarityQuantity.fromJson(json["Hair"]),
        hairTail: RarityQuantity.fromJson(json["Hair_Tail"]),
        eye: RarityQuantity.fromJson(json["Eye"]),
        beard: RarityQuantity.fromJson(json["Beard"]),
        ear: RarityQuantity.fromJson(json["Ear"]),
        hat: RarityQuantity.fromJson(json["Hat"]),
        glasses: RarityQuantity.fromJson(json["Glasses"]),
        cloak: RarityQuantity.fromJson(json["Cloak"]),
        tail: RarityQuantity.fromJson(json["Tail"]),
        item: RarityQuantity.fromJson(json["Item"]),
      );

  Map<String, dynamic> toJson() => {
        "Body": body.toJson(),
        "Skin": skin.toJson(),
        "Hair": hair.toJson(),
        "Hair_Tail": hairTail.toJson(),
        "Eye": eye.toJson(),
        "Beard": beard.toJson(),
        "Ear": ear.toJson(),
        "Hat": hat.toJson(),
        "Glasses": glasses.toJson(),
        "Cloak": cloak.toJson(),
        "Tail": tail.toJson(),
        "Item": item.toJson(),
      };
}
