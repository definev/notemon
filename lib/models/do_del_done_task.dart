import 'package:flutter/material.dart';

class DoDelDoneTodo {
  final int id;
  final int doTodo;
  final int delTodo;
  final int doneTodo;

  DoDelDoneTodo({
    @required this.id,
    @required this.doTodo,
    @required this.delTodo,
    @required this.doneTodo,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doTodo': doTodo,
      'delTodo': delTodo,
      'doneTodo': doneTodo,
    };
  }
}
