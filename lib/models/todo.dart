// To parse this JSON data, do
//
//     final todo = todoFromMap(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

Todo todoFromMap(String str) => Todo.fromMap(json.decode(str));

String todoToMap(Todo data) => json.encode(data.toMap());

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
  });

  String id;
  String timestamp;
  String content;
  String images;
  String state;
  int color;
  String audioPath;
  String audioCode;
  String catagories;

  int get hashCode => hashValues(this.id, this.content);

  @override
  bool operator ==(other) {
    if (other is Todo && other.id == this.id)
      return true;
    else
      return false;
  }

  Todo copyWith({
    String id,
    String timestamp,
    String content,
    String images,
    String state,
    int color,
    String audioPath,
    String audioCode,
    String catagories,
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
      );

  factory Todo.fromMap(Map<String, dynamic> json) => Todo(
        id: json["id"],
        timestamp: json["timestamp"],
        content: json["content"],
        images: json["images"],
        state: json["state"],
        color: json["color"],
        audioPath: json["audioPath"],
        audioCode: json["audioCode"],
        catagories: json["catagories"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "timestamp": timestamp,
        "content": content,
        "images": images,
        "state": state,
        "color": color,
        "audioPath": audioPath,
        "audioCode": audioCode,
        "catagories": catagories,
      };
}
