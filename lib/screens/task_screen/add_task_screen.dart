import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/do_del_done_task/bloc/do_del_done_task_bloc.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/models/do_del_done_task.dart';
import 'package:gottask/models/habit.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';
import 'package:icons_helper/icons_helper.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with BlocCreator {
  int _iconIndex = 0;
  int indexColor = 0;
  List<bool> _catagoryItems = List.generate(9, (index) => false);
  Duration timer = const Duration(hours: 0, minutes: 0);
  final List<String> _achieveLists = [];
  final List<bool> _isDoneAchieveLists = [];
  final StreamController<List<String>> _achieveController =
      StreamController<List<String>>();

  TaskBloc _taskBloc;
  DoDelDoneTaskBloc _doDelDoneTaskBloc;

  final TextEditingController _achieveTextController = TextEditingController();
  final TextEditingController _taskNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _taskBloc = findBloc<TaskBloc>();
    _doDelDoneTaskBloc = findBloc<DoDelDoneTaskBloc>();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(int.parse(colors[indexColor])),
          title: Text(
            'Add Task',
            style: const TextStyle(
              fontFamily: 'Alata',
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                getIconUsingPrefix(name: icons[_iconIndex]),
                color: Colors.white,
              ),
              onPressed: () {
                _buildIconPicker(context);
              },
            ),
          ],
        ),
        bottomNavigationBar: GestureDetector(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            color: Color(int.parse(colors[indexColor])),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Ionicons.ios_add,
                    color: Colors.white,
                  ),
                  Text(
                    ' Add task',
                    style: TextStyle(
                      fontFamily: 'Alata',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () async {
            if (_taskNameTextController.text == null ||
                _taskNameTextController.text == '' ||
                timer == const Duration(hours: 0, minutes: 0)) {
              _buildWarningDialog(context);
            } else {
              int id = await saveTaskID();
              for (int i = 0; i < _achieveLists.length; i++) {
                _achieveLists[i] = _achieveLists[i]
                    .replaceAll(RegExp(r','), 'String.fromCharCode(44)');
              }
              _taskBloc.add(
                AddTaskEvent(
                  Task(
                    id: id,
                    color: indexColor,
                    catagories: _catagoryItems.toString(),
                    icon: _iconIndex,
                    taskName: _taskNameTextController.text,
                    percent: 0,
                    timer: timer.toString(),
                    completeTimer:
                        const Duration(hours: 0, minutes: 0).toString(),
                    achieve: _achieveLists.toString(),
                    isDoneAchieve: _isDoneAchieveLists.toString(),
                  ),
                ),
              );
              int doTask = await onDoingTask();
              int delTask = await readTaskGiveUp();
              int doneTask = await readTaskDone();
              _doDelDoneTaskBloc.add(
                UpdateDoDelDoneTaskEvent(
                  DoDelDoneTask(
                    id: 1,
                    doTask: doTask,
                    delTask: delTask,
                    doneTask: doneTask,
                  ),
                ),
              );
              Navigator.pop(context);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildRename(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Time',
                  style: TextStyle(
                    fontFamily: 'Alata',
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LimitedBox(
                  maxHeight: 100,
                  child: CupertinoTimerPicker(
                    onTimerDurationChanged: (duration) {
                      timer = duration;
                    },
                    mode: CupertinoTimerPickerMode.hm,
                    minuteInterval: 5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTitle('Color'),
              _buildColorPicker(),
              const SizedBox(height: 10),
              _buildTitle('Catagory'),
              _buildCatagoriesPicker(),
              _buildTitle('Achievment'),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(int.parse(colors[indexColor])),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              labelText: 'Achieve goal',
                              labelStyle: TextStyle(
                                fontFamily: 'Alata',
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                            ),
                            controller: _achieveTextController,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_achieveTextController.text != '' &&
                              _achieveTextController != null) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              _achieveLists.add(_achieveTextController.text);
                              _isDoneAchieveLists.add(false);
                              _achieveTextController.clear();
                            });
                          }
                        },
                        child: Material(
                          elevation: 1,
                          color: Color(int.parse(colors[indexColor])),
                          borderRadius: BorderRadiusDirectional.circular(10),
                          child: Container(
                            height: 60,
                            width: 60,
                            child: Icon(
                              Ionicons.ios_add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<List<String>>(
                  initialData: _achieveLists,
                  stream: _achieveController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return const Center(
                        child: Text(
                          'Empty achieve.',
                          style: TextStyle(fontFamily: 'Alata', fontSize: 16),
                        ),
                      );
                    }
                    if (snapshot.data.isEmpty) {
                      return const Center(
                        child: Text(
                          'Empty achieve.',
                          style: TextStyle(fontFamily: 'Alata', fontSize: 16),
                        ),
                      );
                    }
                    return Column(
                      children: List.generate(
                        snapshot.data.length,
                        (index) => _buildAchieve(snapshot, index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Alata',
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildRename() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(int.parse(colors[indexColor])),
            width: 1,
          ),
        ),
        child: TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: 'Task name',
            labelStyle: TextStyle(
              fontFamily: 'Alata',
              color: Colors.grey,
              fontSize: 16,
            ),
            border: InputBorder.none,
          ),
          controller: _taskNameTextController,
        ),
      ),
    );
  }

  Widget _buildCatagoriesPicker() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: 5,
      ),
      child: Wrap(
        children: List.generate(
          catagories.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _catagoryItems[index] = !_catagoryItems[index];
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _catagoryItems[index] == false
                      ? Color(
                          int.parse(
                            colors[indexColor],
                          ),
                        )
                      : Colors.white,
                ),
                color: _catagoryItems[index]
                    ? Color(
                        int.parse(
                          colors[indexColor],
                        ),
                      )
                    : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(
                bottom: 5,
                right: 5,
              ),
              child: FittedBox(
                child: Row(
                  children: <Widget>[
                    Icon(
                      catagoryIcons[index],
                      size: 15,
                      color: _catagoryItems[index] == false
                          ? Color(
                              int.parse(
                                colors[indexColor],
                              ),
                            )
                          : Colors.white,
                    ),
                    Text(
                      ' ${catagories[index]}',
                      style: TextStyle(
                        color: _catagoryItems[index] == false
                            ? Color(
                                int.parse(
                                  colors[indexColor],
                                ),
                              )
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _buildIconPicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: TodoColors.scaffoldWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        height: (MediaQuery.of(context).size.width - 5 * 13) / 7 * 4.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 5),
            const Text(
              'Icon',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Divider(
              height: 4,
            ),
            Wrap(
              direction: Axis.horizontal,
              children: List.generate(
                icons.length,
                (index) => InkWell(
                  onTap: () {
                    setState(() {
                      _iconIndex = index;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width - 5 * 13) / 7,
                    width: (MediaQuery.of(context).size.width - 5 * 13) / 7,
                    decoration: BoxDecoration(
                      color: Color(int.parse(colors[indexColor])),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      getIconUsingPrefix(
                        name: icons[index],
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _buildWarningDialog(BuildContext context) {
    return showDialog(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: TodoColors.scaffoldWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Warning:',
                  style: TextStyle(
                    fontFamily: 'Alata',
                    fontSize: 30,
                    decorationStyle: TextDecorationStyle.double,
                    color: Colors.yellow[900],
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  'Please fill in the blank.',
                  style: TextStyle(
                    fontFamily: 'Alata',
                    fontSize: 20,
                    decorationStyle: TextDecorationStyle.double,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(int.parse(colors[indexColor])),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Alata',
                            fontSize: 20,
                            decorationStyle: TextDecorationStyle.double,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchieve(AsyncSnapshot<List<String>> snapshot, int index) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StringFormatter.format(snapshot.data[index]),
                style: const TextStyle(
                  fontFamily: 'Alata',
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.red.shade800,
                ),
                onTap: () {
                  _achieveLists.removeAt(index);
                  _isDoneAchieveLists.removeAt(index);
                  _achieveController.add(_achieveLists);
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildColorPicker() => Padding(
        padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
        child: Wrap(
          direction: Axis.horizontal,
          children: List.generate(
            colors.length,
            (index) {
              if (indexColor == index) {
                return Container(
                  margin: const EdgeInsets.all(3),
                  height: (MediaQuery.of(context).size.width - 59) / 6,
                  width: (MediaQuery.of(context).size.width - 59) / 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(
                      int.parse(colors[index]),
                    ),
                  ),
                  child: Icon(Icons.check, color: Colors.white),
                );
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    indexColor = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(3),
                  height: (MediaQuery.of(context).size.width - 59) / 6,
                  width: (MediaQuery.of(context).size.width - 59) / 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(
                      int.parse(colors[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _achieveController.close();
    _achieveTextController.dispose();
    _taskNameTextController.dispose();
  }
}
