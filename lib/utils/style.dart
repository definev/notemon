import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle kTitle = TextStyle(
    fontFamily: 'Alata',
    fontSize: 25,
    color: Colors.white,
  );
}

class StringFormatter {
  static String format(String format) {
    String res = format.replaceAll('String.fromCharCode(44)', ',');
    return res;
  }
}
