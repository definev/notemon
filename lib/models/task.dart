// To parse this JSON data, do
//
//     final task = taskFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class Task {
  Task({
    @required this.id,
    @required this.timestamp,
    this.onDoing = false,
    @required this.icon,
    @required this.taskName,
    @required this.timer,
    @required this.percent,
    @required this.color,
    @required this.achieve,
    @required this.completeTimer,
    @required this.isDoneAchieve,
    @required this.catagories,
  });

  String id;
  DateTime timestamp;
  bool onDoing;
  int icon;
  String taskName;
  String timer;
  int percent;
  int color;
  String achieve;
  String completeTimer;
  String isDoneAchieve;
  String catagories;

  Task copyWith({
    String id,
    DateTime timestamp,
    bool onDoing,
    int icon,
    String taskName,
    String timer,
    int percent,
    int color,
    String achieve,
    String completeTimer,
    String isDoneAchieve,
    String catagories,
  }) =>
      Task(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        onDoing: onDoing ?? this.onDoing,
        icon: icon ?? this.icon,
        taskName: taskName ?? this.taskName,
        timer: timer ?? this.timer,
        percent: percent ?? this.percent,
        color: color ?? this.color,
        achieve: achieve ?? this.achieve,
        completeTimer: completeTimer ?? this.completeTimer,
        isDoneAchieve: isDoneAchieve ?? this.isDoneAchieve,
        catagories: catagories ?? this.catagories,
      );

  factory Task.fromFirebaseMap(Map<String, dynamic> json) => Task(
        id: json["id"],
        timestamp: json["timestamp"].toDate(),
        onDoing: json["onDoing"],
        icon: json["icon"],
        taskName: json["taskName"],
        timer: json["timer"],
        percent: json["percent"],
        color: json["color"],
        achieve: json["achieve"],
        completeTimer: json["completeTimer"],
        isDoneAchieve: json["isDoneAchieve"],
        catagories: json["catagories"],
      );

  Map<String, dynamic> toFirebaseMap() => {
        "id": id,
        "timestamp": Timestamp.fromDate(timestamp),
        "onDoing": onDoing ?? false,
        "icon": icon,
        "taskName": taskName,
        "timer": timer,
        "percent": percent,
        "color": color,
        "achieve": achieve,
        "completeTimer": completeTimer,
        "isDoneAchieve": isDoneAchieve,
        "catagories": catagories,
      };

  Map<String, dynamic> toMap() => {
        "id": id,
        "timestamp": timestamp.toIso8601String(),
        "icon": icon,
        "taskName": taskName,
        "timer": timer,
        "percent": percent,
        "color": color,
        "achieve": achieve,
        "completeTimer": completeTimer,
        "isDoneAchieve": isDoneAchieve,
        "catagories": catagories,
      };
}
