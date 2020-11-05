import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gottask/models/quantity_map_sprite_store.dart';
import 'package:gottask/models/sprite.dart';
import 'package:gottask/models/sprite_store.dart';
import 'package:gottask/utils/character_helper.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart' show rootBundle;

class SpriteData {
  Box storage;
  Future<void> init() async {
    storage = await Hive.openBox("spriteData");
  }

  void setSprite(Sprite sprite) => storage.put("sprite", sprite.toJson());

  Sprite get sprite {
    if (storage.get("sprite") != null) {
      Map<String, dynamic> json =
          Map<String, dynamic>.from(storage.get("sprite"));
      return Sprite.fromJson(json);
    } else {
      return Sprite(
        backgroundColor: Colors.amber.toHex(),
        name: "",
        component: Component.defaultComponent,
      );
    }
  }

  void setStore(SpriteStore store) {
    storage.put("store", store.toJson());
  }

  SpriteStore get store {
    if (storage.get("store") != null) {
      Map<String, dynamic> json =
          Map<String, dynamic>.from(storage.get("store"));

      return SpriteStore.fromJson(json);
    } else {
      SpriteStore spriteStore = SpriteStore.defaultStore;
      setStore(spriteStore);
      return spriteStore;
    }
  }

  Future<QuantityMapSpriteStore> _initQuantityMapSpriteStore() async {
    Map<String, dynamic> rawMap = {};

    for (String component in ComponentState.values) {
      Map<String, int> quantityMap = {
        "trivial": 0,
        "rare": 0,
        "superrare": 0,
      };

      bool isOk = true;
      int number = 1;
      while (isOk == true) {
        try {
          await rootBundle
              .load("assets/characters/$component/trivial/$number.png");
          number++;
        } catch (e) {
          print(e);
          isOk = false;
        }
        if (isOk == true) {
          quantityMap["trivial"]++;
        }
      }

      isOk = true;
      number = 1;
      while (isOk == true) {
        try {
          await rootBundle
              .load("assets/characters/$component/rare/$number.png");
          number++;
        } catch (e) {
          print(e);
          isOk = false;
        }

        if (isOk == true) {
          quantityMap["rare"]++;
        }
      }

      isOk = true;
      number = 1;
      while (isOk == true) {
        try {
          await rootBundle
              .load("assets/characters/$component/superrare/$number.png");
          number++;
        } catch (e) {
          print(e);
          isOk = false;
        }
        if (isOk == true) {
          quantityMap["superrare"]++;
        }
      }

      rawMap[component] = quantityMap;
    }

    log(jsonEncode(rawMap));

    return QuantityMapSpriteStore.fromJson(rawMap);
  }

  QuantityMapSpriteStore get quantityMapSpriteStore {
    return QuantityMapSpriteStore.fromJson(<String, dynamic>{
      "Body": <String, dynamic>{"trivial": 12, "rare": 10, "superrare": 11},
      "Skin": <String, dynamic>{"trivial": 24, "rare": 25, "superrare": 21},
      "Hair": <String, dynamic>{"trivial": 42, "rare": 46, "superrare": 48},
      "Hair_Tail": <String, dynamic>{
        "trivial": 32,
        "rare": 35,
        "superrare": 37
      },
      "Eye": <String, dynamic>{"trivial": 11, "rare": 13, "superrare": 11},
      "Beard": <String, dynamic>{"trivial": 3, "rare": 3, "superrare": 2},
      "Ear": <String, dynamic>{"trivial": 5, "rare": 5, "superrare": 4},
      "Hat": <String, dynamic>{"trivial": 9, "rare": 9, "superrare": 8},
      "Glasses": <String, dynamic>{"trivial": 3, "rare": 4, "superrare": 3},
      "Cloak": <String, dynamic>{"trivial": 3, "rare": 3, "superrare": 3},
      "Tail": <String, dynamic>{"trivial": 1, "rare": 1, "superrare": 2},
      "Item": <String, dynamic>{"trivial": 10, "rare": 15, "superrare": 6}
    });
  }
}
