// To parse this JSON data, do
//
//     final task = taskFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gottask/models/model.dart';
import 'package:meta/meta.dart';

class Task {
  Task({
    @required this.id,
    @required this.timestamp,
    this.onDoing = false,
    @required this.taskName,
    @required this.timer,
    @required this.percent,
    @required this.color,
    @required this.achieve,
    @required this.priority,
    @required this.completeTimer,
    @required this.isDoneAchieve,
    @required this.catagories,
  });

  String id;
  DateTime timestamp;
  bool onDoing;
  String taskName;
  String timer;
  int percent;
  int color;
  List<String> achieve;
  PriorityState priority;
  String completeTimer;
  List<bool> isDoneAchieve;
  List<bool> catagories;

  @override
  int get hashCode => hashValues(
        this.id,
        this.timestamp,
        this.taskName,
        this.timer,
        this.percent,
        this.color,
        this.achieve.toString(),
        this.priority,
        this.completeTimer,
        this.isDoneAchieve.toString(),
        this.catagories.toString(),
      );
  bool operator ==(other) {
    if (other is Task && other.id == this.id) {
      return true;
    }
    return false;
  }

  Task copyWith({
    String id,
    DateTime timestamp,
    bool onDoing,
    String taskName,
    String timer,
    int percent,
    int color,
    List<String> achieve,
    String completeTimer,
    List<bool> isDoneAchieve,
    List<bool> catagories,
    PriorityState priority,
  }) =>
      Task(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        onDoing: onDoing ?? this.onDoing,
        taskName: taskName ?? this.taskName,
        timer: timer ?? this.timer,
        percent: percent ?? this.percent,
        color: color ?? this.color,
        achieve: achieve ?? this.achieve,
        completeTimer: completeTimer ?? this.completeTimer,
        isDoneAchieve: isDoneAchieve ?? this.isDoneAchieve,
        catagories: catagories ?? this.catagories,
        priority: priority ?? this.priority,
      );

  factory Task.fromFirebaseMap(Map<String, dynamic> json) {
    List<bool> catagory = [];
    json["catagories"].forEach((data) {
      catagory.add(data);
    });
    List<String> achieve = [];
    json["achieve"]?.forEach((data) {
      achieve.add(data);
    });
    List<bool> isDoneAchieve = [];
    json["isDoneAchieve"]?.forEach((data) {
      isDoneAchieve.add(data);
    });

    return Task(
      id: json["id"],
      timestamp: json["timestamp"].toDate(),
      onDoing: json["onDoing"],
      taskName: json["taskName"],
      timer: json["timer"],
      percent: json["percent"],
      color: json["color"],
      achieve: achieve,
      priority: PriorityState.values[json["priority"]],
      completeTimer: json["completeTimer"],
      isDoneAchieve: isDoneAchieve,
      catagories: catagory,
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      "id": id,
      "timestamp": Timestamp.fromDate(timestamp),
      "onDoing": onDoing ?? false,
      "taskName": taskName,
      "timer": timer,
      "percent": percent,
      "color": color,
      "achieve": achieve,
      "priority": priority.index,
      "completeTimer": completeTimer,
      "isDoneAchieve": isDoneAchieve,
      "catagories": catagories,
    };
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "timestamp": timestamp.toIso8601String(),
        "taskName": taskName,
        "timer": timer,
        "percent": percent,
        "color": color,
        "achieve": achieve.toString(),
        "priority": priority.index,
        "completeTimer": completeTimer,
        "isDoneAchieve": isDoneAchieve.toString(),
        "catagories": catagories.toString(),
      };
}
