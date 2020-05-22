import 'package:flutter/material.dart';

class TodayTask {
  int id;
  String content;
  bool isDone;
  String images;
  int color;
  String audioPath;
  String catagories;
  TodayTask({
    @required this.content,
    @required this.id,
    @required this.images,
    @required this.isDone,
    @required this.color,
    @required this.audioPath,
    @required this.catagories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'images': images.toString(),
      'isDone': isDone == true ? 1 : 0,
      'color': color,
      'audioPath': audioPath,
      'catagories': catagories,
    };
  }

  TodayTask copyWith({
    int id,
    String content,
    bool isDone,
    String images,
    int color,
    String audioPath,
    String catagories,
  }) {
    this.id = id ?? this.id;
    this.content = content ?? this.content;
    this.isDone = isDone ?? this.isDone;
    this.images = images ?? this.images;
    this.color = color ?? this.color;
    this.audioPath = audioPath ?? this.audioPath;
    this.catagories = catagories ?? this.catagories;
    return TodayTask(
      id: this.id,
      content: this.content,
      isDone: this.isDone,
      images: this.images,
      color: this.color,
      audioPath: this.audioPath,
      catagories: this.catagories,
    );
  }
}
