import 'package:flutter/material.dart';

class Habit {
  int id;
  int icon;
  String habitName;
  String timer;
  int color;
  int percent;
  String completeTimer;
  String achieve;
  String isDoneAchieve;
  String catagories;
  Habit({
    @required this.id,
    @required this.color,
    @required this.icon,
    @required this.habitName,
    @required this.timer,
    @required this.completeTimer,
    @required this.percent,
    @required this.achieve,
    @required this.isDoneAchieve,
    @required this.catagories,
  });
  Map<String, dynamic> toMap() => {
      'id': id,
      'icon': icon,
      'habitName': habitName,
      'timer': timer,
      'percent': percent,
      'color': color,
      'achieve': achieve,
      'completeTimer': completeTimer,
      'isDoneAchieve': isDoneAchieve,
      'catagories': catagories,
    };
}
