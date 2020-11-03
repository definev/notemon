import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gottask/models/shared.dart';
import 'package:meta/meta.dart';

class Todo {
  Todo({
    @required this.id,
    @required this.timestamp,
    @required this.content,
    @required this.images,
    @required this.state,
    @required this.color,
    @required this.audioPath,
    @required this.audioCode,
    @required this.catagories,
    @required this.priority,
    @required this.note,
  });

  String id;
  DateTime timestamp;
  String content;
  String images;
  String state;
  int color;
  String audioPath;
  String audioCode;
  List<bool> catagories;
  PriorityState priority;
  String note;

  Todo copyWith({
    String id,
    DateTime timestamp,
    String content,
    String images,
    String state,
    int color,
    String audioPath,
    String audioCode,
    List<bool> catagories,
    PriorityState priority,
    String note,
  }) =>
      Todo(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        content: content ?? this.content,
        images: images ?? this.images,
        state: state ?? this.state,
        color: color ?? this.color,
        audioPath: audioPath ?? this.audioPath,
        audioCode: audioCode ?? this.audioCode,
        catagories: catagories ?? this.catagories,
        priority: priority ?? this.priority,
        note: note ?? this.note,
      );

  @override
  int get hashCode => hashValues(
        this.id,
        this.timestamp,
        this.content,
        this.images,
        this.state,
        this.color,
        this.audioPath,
        this.audioCode,
        this.catagories.toString(),
        this.priority,
        this.note,
      );
  bool operator ==(other) {
    if (other is Todo && other.id == this.id) {
      return true;
    }
    return false;
  }

  factory Todo.fromFirebaseMap(Map<String, dynamic> json) {
    List<bool> category = [];
    json["catagories"].forEach((cata) => category.add(cata));

    return Todo(
      id: json["id"],
      timestamp: json["timestamp"].toDate(),
      content: json["content"],
      images: json["images"],
      state: json["state"],
      color: json["color"],
      audioPath: json["audioPath"],
      audioCode: json["audioCode"],
      catagories: category,
      priority: PriorityState.values[json["priority"]],
      note: json["note"],
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "timestamp": timestamp.toIso8601String(),
        "content": content,
        "images": images,
        "state": state,
        "color": color,
        "audioPath": audioPath,
        "audioCode": audioCode,
        "catagories": catagories.toString(),
        "priority": priority.index,
        "note": note,
      };

  Map<String, dynamic> toFirebaseMap() => {
        "id": id,
        "timestamp": Timestamp.fromDate(timestamp),
        "content": content,
        "images": images,
        "state": state,
        "color": color,
        "audioPath": audioPath,
        "audioCode": audioCode,
        "catagories": catagories,
        "priority": priority.index,
        "note": note,
      };
}

extension TodoExt on String {
  List<dynamic> parseNote() {
    if (this == "[]") return [];
    var data = jsonDecode(this);

    return data;
  }
}
