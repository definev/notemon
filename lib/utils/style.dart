import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart' as diacritic;

class NotemonTextStyle {
  static const TextStyle kTinySmallStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 13,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kNormalSuperSmallStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 14,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kNormalSmallStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 15,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kNormalStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 16,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kMediumStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 18,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kTitleStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 20,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kBigTitleStyle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 25,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static const TextStyle kRetroStyle = TextStyle(
    fontFamily: 'Pixel',
    fontSize: 30,
    color: Colors.black,
    decoration: TextDecoration.none,
  );
}

extension AccentedRemove on String {
  String removeDiacritics() {
    return diacritic.removeDiacritics(this);
  }
}

class StringFormatter {
  static String format(String format) {
    String res = format.replaceAll('String.fromCharCode(44)', ',');
    return res;
  }
}
