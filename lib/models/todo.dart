// To parse this JSON data, do
//
//     final todo = todoFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Todo {
  final int id;
  final String content;
  final bool isDone;
  final int color;
  final String images;
  final String audioPath;
  final String catagories;

  Todo({
    @required this.id,
    @required this.content,
    @required this.images,
    @required this.isDone,
    @required this.color,
    @required this.audioPath,
    @required this.catagories,
  });

  factory Todo.fromJson(String str) => Todo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Todo.fromMap(Map<String, dynamic> json) => Todo(
        id: json["id"],
        content: json["content"],
        images: json["images"],
        isDone: json["isDone"] == 1 ? true : false,
        color: json["color"],
        audioPath: json["audioPath"],
        catagories: json["catagories"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "content": content,
        "images": images,
        "isDone": isDone == true ? 1 : 0,
        "color": color,
        "audioPath": audioPath,
        "catagories": catagories,
      };
  Todo copyWith({
    int id,
    String content,
    String images,
    String imageURLs,
    bool isDone,
    int color,
    String audioPath,
    String catagories,
  }) =>
      Todo(
        id: id ?? this.id,
        content: content ?? this.content,
        images: images ?? this.images,
        isDone: isDone ?? this.isDone,
        color: color ?? this.color,
        audioPath: audioPath ?? this.audioPath,
        catagories: catagories ?? this.catagories,
      );
}
