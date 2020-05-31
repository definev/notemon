// To parse this JSON data, do
//
//     final todo = todoFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Todo {
    final String id;
    final String content;
    final String images;
    final String state;
    final int color;
    final String audioPath;
    final String audioCode;
    final String catagories;

    Todo({
        @required this.id,
        @required this.content,
        @required this.images,
        @required this.state,
        @required this.color,
        @required this.audioPath,
        @required this.audioCode,
        @required this.catagories,
    });

    Todo copyWith({
        String id,
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
            content: content ?? this.content,
            images: images ?? this.images,
            state: state ?? this.state,
            color: color ?? this.color,
            audioPath: audioPath ?? this.audioPath,
            audioCode: audioCode ?? this.audioCode,
            catagories: catagories ?? this.catagories,
        );

    factory Todo.fromJson(String str) => Todo.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Todo.fromMap(Map<String, dynamic> json) => Todo(
        id: json["id"],
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
        "content": content,
        "images": images,
        "state": state,
        "color": color,
        "audioPath": audioPath,
        "audioCode": audioCode,
        "catagories": catagories,
    };
}
