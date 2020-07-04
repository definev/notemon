import 'package:flutter/material.dart';

const TextStyle kTinySmallStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 13,
  color: Colors.black,
  decoration: TextDecoration.none,
);

const TextStyle kNormalSuperSmallStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 14,
  color: Colors.black,
  decoration: TextDecoration.none,
);

const TextStyle kNormalSmallStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 15,
  color: Colors.black,
  decoration: TextDecoration.none,
);

const TextStyle kNormalStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 16,
  color: Colors.black,
  decoration: TextDecoration.none,
);

const TextStyle kMediumStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 18,
  color: Colors.black,
  decoration: TextDecoration.none,
);

const TextStyle kTitleStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 20,
  color: Colors.black,
  decoration: TextDecoration.none,
);

const TextStyle kBigTitleStyle = TextStyle(
  fontFamily: 'Alata',
  fontSize: 25,
  color: Colors.black,
  decoration: TextDecoration.none,
);

class StringFormatter {
  static String format(String format) {
    String res = format.replaceAll('String.fromCharCode(44)', ',');
    return res;
  }
}
