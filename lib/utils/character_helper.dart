import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:image/image.dart' as imglib;
import 'package:flutter/services.dart' show rootBundle;

class ItemArrangerment<IAType> {
  ItemArrangerment({
    this.shadow,
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

  final IAType shadow;
  final IAType body;
  final IAType skin;
  final IAType hair;
  final IAType hairTail;
  final IAType eye;
  final IAType beard;
  final IAType ear;
  final IAType hat;
  final IAType glasses;
  final IAType cloak;
  final IAType tail;
  final IAType item;

  ItemArrangerment copyWith({
    IAType shadow,
    IAType body,
    IAType skin,
    IAType hair,
    IAType hairTail,
    IAType eye,
    IAType beard,
    IAType ear,
    IAType hat,
    IAType glasses,
    IAType cloak,
    IAType tail,
    IAType item,
  }) =>
      ItemArrangerment(
        shadow: shadow ?? this.shadow,
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

  factory ItemArrangerment.fromRawJson(String str) =>
      ItemArrangerment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ItemArrangerment.fromJson(Map<String, IAType> json) =>
      ItemArrangerment(
        shadow: json["Shadow"],
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

  Map<String, IAType> toJson() => {
        "Shadow": shadow,
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

  Map<String, IAType> toNotNullJson() {
    Map<String, IAType> json = this.toJson();
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class CharacterAnimationPatterm {
  static const List<int> front = const [0, 1, 2];
  static const List<int> left = const [3, 4, 5];
  static const List<int> right = const [6, 7, 8];
  static const List<int> back = const [9, 10, 11];
  static const List<List<int>> values = const [front, left, right, back];
}

Future<Uint8List> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('$path');
  Uint8List imageUint8List = byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  Uint8List imageListInt = imageUint8List;

  return imageListInt;
}

class CharacterHelper {
  static String getImagePath(String component, String rarity, int index) =>
      "assets/characters/$component/$rarity/$index.png";

  final ItemArrangerment<String> items;
  List<Uint8List> _rawIntList = [];
  ItemArrangerment<Uint8List> _frontList = [];
  List<Uint8List> _leftList = [];
  List<Uint8List> _rightList = [];
  List<Uint8List> _backList = [];

  List<Uint8List> get front => _frontList;
  List<Uint8List> get left => _leftList;
  List<Uint8List> get right => _rightList;
  List<Uint8List> get back => _backList;

  bool isInit = false;

  CharacterHelper(this.items);

  imglib.Image _mergeImage() {
    List<imglib.Image> imageList =
        _rawIntList.map((file) => imglib.decodeImage(file)).toList();
    imglib.Image finalMergedImage = imageList[0];
    imageList.removeAt(0);

    imageList.forEach((image) {
      imglib.Image mergedImage = imglib.Image(
        finalMergedImage.width + image.width,
        max(finalMergedImage.height, image.height),
      );
      imglib.copyInto(mergedImage, finalMergedImage, blend: false);
      imglib.copyInto(mergedImage, image,
          dstX: finalMergedImage.width, blend: false);
      finalMergedImage = mergedImage;
    });

    return finalMergedImage;
  }

  List<Uint8List> _splitImage() {
    // convert image to image from image package
    imglib.Image image = _mergeImage();

    int x = 0, y = 0;
    int width = (image.width / 3).round();
    int height = (image.height / 4).round();

    // split image to parts
    List<imglib.Image> parts = List<imglib.Image>();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }

    // convert image from image package to Image Widget to display
    List<Uint8List> output = List<Uint8List>();
    for (var img in parts) output.add(imglib.encodePng(img));

    return output;
  }

  Future<void> init() async {
    for (var path in items.toJson().values) {
      if (path != null) _rawIntList.add(await getImageFileFromAssets(path));
    }
    List<Uint8List> splitImage = _splitImage();
    List<List<Uint8List>> _patternList = [];
    CharacterAnimationPatterm.values.forEach((patterm) => _patternList
        .add(patterm.map<Uint8List>((pos) => splitImage[pos]).toList()));

    _frontList = _patternList[0];
    _leftList = _patternList[1];
    _rightList = _patternList[2];
    _backList = _patternList[3];

    isInit = true;
  }
}
