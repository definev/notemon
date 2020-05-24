// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Task {
    final int id;
    final int icon;
    final String taskName;
    final String timer;
    final int percent;
    final int color;
    final String achieve;
    final String completeTimer;
    final String isDoneAchieve;
    final String catagories;

    Task({
        @required this.id,
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

    Task copyWith({
        int id,
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

    factory Task.fromJson(String str) => Task.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Task.fromMap(Map<String, dynamic> json) => Task(
        id: json["id"],
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

    Map<String, dynamic> toMap() => {
        "id": id,
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
