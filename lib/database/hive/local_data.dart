import 'package:hive/hive.dart';

class LocalData {
  Box storage;
  Future<void> init() async {
    storage = await Hive.openBox("local");
  }

  String getLang() {
    String res = storage.get("lang");
    if (res == null) {
      storage.put("lang", "vi");
    }

    return storage.get("lang");
  }

  void setLang(String lang) {
    storage.put("lang", lang);
  }
}
