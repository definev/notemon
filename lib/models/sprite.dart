import 'package:flutter/material.dart';
import 'package:gottask/utils/character_helper.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class FormatColor {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class Sprite {
  Sprite({
    @required this.name,
    @required this.component,
    @required this.backgroundColor,
  });

  final String name;
  final Component component;
  final String backgroundColor;

  Sprite copyWith({
    String name,
    Component component,
    String backgroundColor,
  }) =>
      Sprite(
        name: name ?? this.name,
        component: component ?? this.component,
        backgroundColor: backgroundColor ?? this.backgroundColor,
      );

  factory Sprite.fromRawJson(String str) => Sprite.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sprite.fromJson(Map<String, dynamic> json) => Sprite(
        name: json["name"],
        component: Component.fromJson(json["component"]),
        backgroundColor: json["backgroundColor"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "component": component.toJson(),
        "backgroundColor": backgroundColor,
      };
}

class Component {
  static Component defaultComponent = Component(
    body: ImageUtils.getComponentImagePath("Body", RarityState.trivial, 1),
    hair: ImageUtils.getComponentImagePath("Hair", RarityState.trivial, 1),
    eye: ImageUtils.getComponentImagePath("Eye", RarityState.trivial, 1),
    ear: ImageUtils.getComponentImagePath("Ear", RarityState.trivial, 1),
  );

  Component({
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

  final String body;
  final String skin;
  final String hair;
  final String hairTail;
  final String eye;
  final String beard;
  final String ear;
  final String hat;
  final String glasses;
  final String cloak;
  final String tail;
  final String item;

  Component copyWith({
    String body,
    String skin,
    String hair,
    String hairTail,
    String eye,
    String beard,
    String ear,
    String hat,
    String glasses,
    String cloak,
    String tail,
    String item,
  }) =>
      Component(
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

  factory Component.fromRawJson(String str) =>
      Component.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Component.fromJson(Map<String, dynamic> json) => Component(
        body: json["Body"],
        skin: json["Skin"],
        hair: json["Hair"],
        hairTail: json["Hair_Tail"],
        eye: json["Eye"],
        beard: json["Beard"],
        ear: json["Ear"],
        hat: json["Hat"],
        glasses: json["Glasses"],
        cloak: json["Cloak"],
        tail: json["Tail"],
        item: json["Item"],
      );

  Map<String, dynamic> toJson() => {
        "Body": body,
        "Skin": skin,
        "Hair": hair,
        "Hair_Tail": hairTail,
        "Eye": eye,
        "Beard": beard,
        "Ear": ear,
        "Hat": hat,
        "Glasses": glasses,
        "Cloak": cloak,
        "Tail": tail,
        "Item": item,
      };
}
