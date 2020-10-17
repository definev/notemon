import 'package:hive/hive.dart';

class LocalData {
  static Box storage;
  static Future<void> init() async {
    storage = await Hive.openBox("local");
  }

  static String getLang() {
    String res = storage.get("lang");
    if (res == null) {
      storage.put("lang", "vi");
    }

    return storage.get("lang");
  }

  static void setLang(String lang) {
    storage.put("lang", lang);
  }
}
