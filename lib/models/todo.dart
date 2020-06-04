import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  });

  String id;
  DateTime timestamp;
  String content;
  String images;
  String state;
  int color;
  String audioPath;
  String audioCode;
  String catagories;

  Todo copyWith({
    String id,
    DateTime timestamp,
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
        this.catagories,
      );
  bool operator ==(other) {
    if (other is Todo && other.id == this.id) {
      return true;
    }
    return false;
  }

  factory Todo.fromFirebaseMap(Map<String, dynamic> json) => Todo(
        id: json["id"],
        timestamp: json["timestamp"].toDate(),
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
        "timestamp": timestamp.toIso8601String(),
        "content": content,
        "images": images,
        "state": state,
        "color": color,
        "audioPath": audioPath,
        "audioCode": audioCode,
        "catagories": catagories,
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
      };
}
