import 'package:gottask/database/hive/local_data.dart';
import 'package:gottask/database/hive/sprite_data.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotemonHive {
  static LocalData localData = LocalData();
  static SpriteData spriteData = SpriteData();

  static Future<void> init() async {
    await Hive.initFlutter();
    await localData.init();
    await spriteData.init();
  }
}
