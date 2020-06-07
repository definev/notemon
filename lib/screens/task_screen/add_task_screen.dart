import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';
import 'package:icons_helper/icons_helper.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with BlocCreator {
  int _iconIndex = 0;
  int indexColor = 0;
  List<bool> _catagoryItems =
      List.generate(catagories.length, (index) => false);
  Duration timer = const Duration(hours: 0, minutes: 0);
  final List<String> _achieveLists = [];
  final List<bool> _isDoneAchieveLists = [];
  final StreamController<List<String>> _achieveController =
      StreamController<List<String>>();

  TaskBloc _taskBloc;
  FirebaseRepository _repository;

  final TextEditingController _achieveTextController = TextEditingController();
  final TextEditingController _taskNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _taskBloc = findBloc<TaskBloc>();
    _repository = findBloc<FirebaseRepository>();

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Theme(
        data: Theme.of(context)
            .copyWith(accentColor: Color(int.parse(colors[indexColor]))),
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
                      style: kNormalStyle.copyWith(color: Colors.white),
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
                for (int i = 0; i < _achieveLists.length; i++) {
                  _achieveLists[i] = _achieveLists[i]
                      .replaceAll(RegExp(r','), 'String.fromCharCode(44)');
                }
                String id = Uuid().v1();
                Task _task = Task(
                  id: id,
                  timestamp: Timestamp.now().toDate(),
                  onDoing: false,
                  color: indexColor,
                  catagories: _catagoryItems,
                  icon: _iconIndex,
                  taskName: _taskNameTextController.text,
                  percent: 0,
                  timer: timer.toString(),
                  completeTimer:
                      const Duration(hours: 0, minutes: 0).toString(),
                  achieve: _achieveLists,
                  isDoneAchieve: _isDoneAchieveLists,
                );
                _taskBloc.add(AddTaskEvent(task: _task));
                if (await checkConnection()) {
                  _repository.updateTaskToFirebase(_task);
                }
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
                    style: kNormalStyle.copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 3),
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
                _buildTitle('Color'),
                const SizedBox(height: 3),
                _buildColorPicker(),
                const SizedBox(height: 10),
                _buildTitle('Catagory'),
                const SizedBox(height: 3),
                _buildCatagoriesPicker(context),
                _buildTitle('Achievment'),
                const SizedBox(height: 3),
                _buildAchievment(context),
                const SizedBox(height: 20),
                _buildListAchievment(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildListAchievment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<List<String>>(
        initialData: _achieveLists,
        stream: _achieveController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const Center(
              child: Text(
                'Empty achieve.',
                style: kNormalSmallStyle,
              ),
            );
          }
          if (snapshot.data.isEmpty) {
            return const Center(
              child: Text(
                'Empty achieve.',
                style: kNormalSmallStyle,
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
    );
  }

  Widget _buildAchievment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: SizedBox(
        height: 52,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(int.parse(colors[indexColor])),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    labelText: 'Achieve goal',
                    labelStyle: kNormalStyle.copyWith(color: Colors.grey),
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
                  height: 52,
                  width: 52,
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
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: kNormalStyle.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildRename() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
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
            labelStyle: kNormalStyle.copyWith(color: Colors.grey),
            border: InputBorder.none,
          ),
          controller: _taskNameTextController,
        ),
      ),
    );
  }

  Widget _buildCatagoriesPicker(BuildContext context) {
    return SizedBox(
      height: 46.0 * 4 - 10,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: GridView(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: MediaQuery.of(context).size.width / 92,
            ),
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
                          : TodoColors.scaffoldWhite,
                      width: 1.2,
                    ),
                    color: _catagoryItems[index]
                        ? Color(
                            int.parse(
                              colors[indexColor],
                            ),
                          )
                        : TodoColors.scaffoldWhite,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: const EdgeInsets.all(2.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        catagories[index]["iconData"],
                        size: 17,
                        color: _catagoryItems[index] == false
                            ? Color(
                                int.parse(
                                  colors[indexColor],
                                ),
                              )
                            : TodoColors.scaffoldWhite,
                      ),
                      Text(
                        '${catagories[index]["name"]}',
                        style: TextStyle(
                          fontFamily: 'Source_Sans_Pro',
                          fontSize: 16,
                          color: _catagoryItems[index] == false
                              ? Color(
                                  int.parse(
                                    colors[indexColor],
                                  ),
                                )
                              : TodoColors.scaffoldWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _buildIconPicker(BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: TodoColors.scaffoldWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 5),
                  Text(
                    'Icon',
                    style: TextStyle(fontFamily: 'Alata', fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Divider(),
                  Wrap(
                    direction: Axis.horizontal,
                    children: List.generate(
                      icons.length,
                      (index) {
                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _iconIndex = index;
                                Navigator.pop(context);
                              });
                            },
                            child: Material(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  getIconUsingPrefix(
                                    name: icons[index],
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                              color: Color(int.parse(colors[indexColor])),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

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
                  style: kTitleStyle,
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
                          style: kTitleStyle.copyWith(color: Colors.white),
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
          boxShadow: [
            BoxShadow(
              color: Color(int.parse(colors[indexColor])).withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
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
                style: kNormalSuperSmallStyle,
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          height: 50 * 2.0 + 25,
          child: GridView(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            children: List.generate(
              colors.length,
              (index) {
                if (indexColor == index) {
                  return Container(
                    margin: const EdgeInsets.all(3),
                    height: 50,
                    width: 50,
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
                    height: 50,
                    width: 50,
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
