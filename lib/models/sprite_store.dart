import 'package:gottask/models/store.dart';
import 'dart:convert';

class SpriteStore {
  static SpriteStore defaultStore = SpriteStore.fromJson({
    "Body": {
      "trivial": ["assets/characters/Body/trivial/1.png"],
      "rare": [""],
      "superrare": [""]
    },
    "Skin": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Hair": {
      "trivial": ["assets/characters/Hair/trivial/1.png"],
      "rare": [""],
      "superrare": [""]
    },
    "Hair_Tail": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Eye": {
      "trivial": ["assets/characters/Eye/trivial/1.png"],
      "rare": [""],
      "superrare": [""]
    },
    "Beard": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Ear": {
      "trivial": ["assets/characters/Ear/trivial/1.png"],
      "rare": [""],
      "superrare": [""]
    },
    "Hat": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Glasses": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Cloak": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Tail": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    },
    "Item": {
      "trivial": [""],
      "rare": [""],
      "superrare": [""]
    }
  });

  SpriteStore({
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

  final Store body;
  final Store skin;
  final Store hair;
  final Store hairTail;
  final Store eye;
  final Store beard;
  final Store ear;
  final Store hat;
  final Store glasses;
  final Store cloak;
  final Store tail;
  final Store item;

  SpriteStore copyWith({
    Store body,
    Store skin,
    Store hair,
    Store hairTail,
    Store eye,
    Store beard,
    Store ear,
    Store hat,
    Store glasses,
    Store cloak,
    Store tail,
    Store item,
  }) =>
      SpriteStore(
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

  factory SpriteStore.fromRawJson(String str) =>
      SpriteStore.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SpriteStore.fromJson(Map<String, dynamic> json) => SpriteStore(
        body: Store.fromJson(json["Body"].cast<String, dynamic>()),
        skin: Store.fromJson(json["Skin"].cast<String, dynamic>()),
        hair: Store.fromJson(json["Hair"].cast<String, dynamic>()),
        hairTail: Store.fromJson(json["Hair_Tail"].cast<String, dynamic>()),
        eye: Store.fromJson(json["Eye"].cast<String, dynamic>()),
        beard: Store.fromJson(json["Beard"].cast<String, dynamic>()),
        ear: Store.fromJson(json["Ear"].cast<String, dynamic>()),
        hat: Store.fromJson(json["Hat"].cast<String, dynamic>()),
        glasses: Store.fromJson(json["Glasses"].cast<String, dynamic>()),
        cloak: Store.fromJson(json["Cloak"].cast<String, dynamic>()),
        tail: Store.fromJson(json["Tail"].cast<String, dynamic>()),
        item: Store.fromJson(json["Item"].cast<String, dynamic>()),
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
