import 'package:flutter/cupertino.dart';

class DoDelDoneHabit {
  final int id;

  final int doTask;
  final int delTask;
  final int doneTask;

  DoDelDoneHabit({
    @required this.id,
    @required this.doTask,
    @required this.delTask,
    @required this.doneTask,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doTask': doTask,
      'delTask': delTask,
      'doneTask': doneTask,
    };
  }
}
