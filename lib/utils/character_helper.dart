import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:gottask/models/sprite.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/services.dart' show rootBundle;

class ComponentState {
  static const String beard = "Beard";
  static const String body = "Body";
  static const String cloak = "Cloak";
  static const String ear = "Ear";
  static const String eye = "Eye";
  static const String glasses = "Glasses";
  static const String hat = "Hat";
  static const String item = "Item";
  static const String tail = "Tail";
  static const String skin = "Skin";
  static const String hair = "Hair";
  static const String hairTail = "Hair_Tail";

  static const List<String> values = [
    body,
    skin,
    hair,
    hairTail,
    eye,
    beard,
    ear,
    hat,
    glasses,
    cloak,
    tail,
    item
  ];
}

class RarityState {
  static const String rare = "rare";
  static const String superrare = "superrare";
  static const String trivial = "trivial";
}

enum AnimationState { front, right, back, left }

class AnimationStateImpl {
  final List<Uint8List> front;
  final List<Uint8List> left;
  final List<Uint8List> right;
  final List<Uint8List> back;

  AnimationStateImpl(this.front, this.left, this.right, this.back);
}

class SpriteAnimationPatterm {
  static const List<int> front = const [0, 1, 2];
  static const List<int> left = const [3, 4, 5];
  static const List<int> right = const [6, 7, 8];
  static const List<int> back = const [9, 10, 11];
  static const List<List<int>> values = const [front, left, right, back];
}

class ImageUtils {
  static String getComponentImagePath(
      String component, String rarity, int index) {
    dev.log("assets/characters/$component/$rarity/$index.png");

    return "assets/characters/$component/$rarity/$index.png";
  }

  static Future<Uint8List> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');
    Uint8List imageUint8List = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    Uint8List imageListInt = imageUint8List;
    return imageListInt;
  }

  static imglib.Image mergeImage(List<Uint8List> rawIntList) {
    List<imglib.Image> imageList =
        rawIntList.map((file) => imglib.decodeImage(file)).toList();
    imglib.Image finalMergedImage = imageList[0];
    imageList.removeAt(0);

    imageList.forEach((image) {
      imglib.Image mergedImage = imglib.Image(
        finalMergedImage.width,
        finalMergedImage.height,
      );
      mergedImage = imglib.copyInto(mergedImage, finalMergedImage, blend: true);
      mergedImage = imglib.copyInto(mergedImage, image, blend: true);
      finalMergedImage = mergedImage;
    });

    return finalMergedImage;
  }

  static List<Uint8List> splitImage(imglib.Image image) {
    int x = 0, y = 0;
    int width = (image.width ~/ 3);
    int height = (image.height ~/ 4);

    dev.log("Image: $width x $height");

    // split image to parts
    List<imglib.Image> parts = List<imglib.Image>();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        imglib.Image _cropImage = imglib.copyCrop(image, x, y, width, height);
        _cropImage = imglib.pixelate(_cropImage, 1);
        parts.add(_cropImage);
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

  ///[image] is raw image
  ///
  ///[pattern] is 4 state of animation [front, back, left, right]
  static Future<AnimationStateImpl> getAnimationImage(String path,
      [List<int> pattern = SpriteAnimationPatterm.front]) async {
    imglib.Image image = imglib.decodePng(await getImageFileFromAssets(path));
    List<Uint8List> _splitImage = ImageUtils.splitImage(image);

    List<List<Uint8List>> _patternList = [];
    SpriteAnimationPatterm.values.forEach((patterm) => _patternList
        .add(patterm.map<Uint8List>((pos) => _splitImage[pos]).toList()));

    return AnimationStateImpl(
        _patternList[0], _patternList[1], _patternList[2], _patternList[3]);
  }
}

class SpriteHelper {
  final Component component;
  List<Uint8List> _rawIntList = [];

  List<Uint8List> _frontList = [];
  List<Uint8List> _leftList = [];
  List<Uint8List> _rightList = [];
  List<Uint8List> _backList = [];

  List<Uint8List> get front => _frontList;
  List<Uint8List> get left => _leftList;
  List<Uint8List> get right => _rightList;
  List<Uint8List> get back => _backList;

  bool isInit = false;
  imglib.Image _rawImage;

  SpriteHelper({@required this.component});

  Future<void> init() async {
    for (var path in component.toJson().values) {
      if (path != null) {
        if (path != "") {
          _rawIntList.add(await ImageUtils.getImageFileFromAssets(path));
        }
      }
    }

    _rawImage = ImageUtils.mergeImage(_rawIntList);

    List<Uint8List> splitImage = ImageUtils.splitImage(_rawImage);
    List<List<Uint8List>> _patternList = [];
    SpriteAnimationPatterm.values.forEach((patterm) => _patternList
        .add(patterm.map<Uint8List>((pos) => splitImage[pos]).toList()));

    _frontList = _patternList[0];
    _leftList = _patternList[1];
    _rightList = _patternList[2];
    _backList = _patternList[3];

    isInit = true;
  }
}
