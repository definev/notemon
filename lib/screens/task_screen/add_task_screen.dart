import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with BlocCreator, FilterMixin {
  int indexColor = 0;
  List<bool> _categoryItems =
      List.generate(catagories.length, (index) => false);
  Duration timer = const Duration(hours: 0, minutes: 0);

  final List<String> _achieveLists = [];
  final List<bool> _isDoneAchieveLists = [];
  PriorityState _priority = PriorityState.Low;

  final StreamController<List<String>> _achieveController =
      StreamController<List<String>>();

  TaskBloc _taskBloc;
  FirebaseApi _repository;

  final TextEditingController _achieveTextController = TextEditingController();
  final TextEditingController _taskNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _taskBloc = findBloc<TaskBloc>();
    _repository = findBloc<FirebaseApi>();

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Theme(
        data: Theme.of(context)
            .copyWith(accentColor: colors.parseColor(indexColor)),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: colors.parseColor(indexColor),
            title: Text(
              'Add Task'.tr,
              style: const TextStyle(
                fontFamily: 'Alata',
                color: Colors.white,
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              color: colors.parseColor(indexColor),
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
                      ' ${"Add Task".tr.capitalize}',
                      style: NotemonTextStyle.kNormalStyle
                          .copyWith(color: Colors.white),
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
                  catagories: _categoryItems,
                  priority: _priority,
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
                  _repository.firebase.updateTaskToFirebase(_task);
                }
                Get.back();
              }
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 20,
              left: 15,
              right: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildRename(),
                _buildTitle('Time'),
                _buildTimePicker(),
                _buildTitle('Color'),
                _buildColorPicker(),
                _buildTitle('Priority'),
                _buildPriorityPicker(),
                _buildTitle('Category'),
                _buildCatagoriesPicker(context),
                _buildTitle('Achievement'),
                _buildAchievement(context),
                _buildListAchievement(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LimitedBox _buildTimePicker() {
    return LimitedBox(
      maxHeight: 100,
      child: CupertinoTimerPicker(
        onTimerDurationChanged: (duration) {
          timer = duration;
        },
        mode: CupertinoTimerPickerMode.hm,
        minuteInterval: 5,
      ),
    );
  }

  Padding _buildListAchievement() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: StreamBuilder<List<String>>(
        initialData: _achieveLists,
        stream: _achieveController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(
              child: Text(
                'Empty achieve.'.tr,
                style: NotemonTextStyle.kNormalSmallStyle,
              ),
            );
          }
          if (snapshot.data.isEmpty) {
            return Center(
              child: Text(
                'Empty achieve.'.tr,
                style: NotemonTextStyle.kNormalSmallStyle,
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

  Widget _buildAchievement(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.parseColor(indexColor),
                  width: 1.2,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  labelText: 'Add achievement'.tr,
                  labelStyle: NotemonTextStyle.kNormalStyle
                      .copyWith(color: Colors.grey),
                  border: InputBorder.none,
                ),
                controller: _achieveTextController,
                style: NotemonTextStyle.kNormalStyle.copyWith(
                  fontFamily: "Source_Sans_Pro",
                ),
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
              color: colors.parseColor(indexColor),
              borderRadius: BorderRadiusDirectional.circular(10),
              child: Container(
                height: 50,
                width: 50,
                child: Icon(
                  Ionicons.ios_add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 5, top: 10),
      child: Text(
        title.tr,
        style: NotemonTextStyle.kNormalStyle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildRename() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.parseColor(indexColor),
          width: 1,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText: 'Task name'.tr,
          labelStyle:
              NotemonTextStyle.kNormalStyle.copyWith(color: Colors.grey),
          border: InputBorder.none,
        ),
        controller: _taskNameTextController,
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Row(
      children: [
        _priorityTile(PriorityState.High.index),
        SizedBox(width: 10),
        _priorityTile(PriorityState.Medium.index),
        SizedBox(width: 10),
        _priorityTile(PriorityState.Low.index),
      ],
    );
  }

  Widget _priorityTile(int value) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_priority != PriorityState.values[value]) {
            _priority = PriorityState.values[value];
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 45,
        width: (MediaQuery.of(context).size.width - 50) / 3,
        decoration: BoxDecoration(
          color: _priority != PriorityState.values[value]
              ? TodoColors.scaffoldWhite
              : setPriorityColor(priorityList[value]),
          border: Border.all(
            color: _priority == PriorityState.values[value]
                ? TodoColors.scaffoldWhite
                : setPriorityColor(priorityList[value]),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            priorityList[value].tr,
            style: NotemonTextStyle.kNormalStyle.copyWith(
              color: _priority == PriorityState.values[value]
                  ? TodoColors.scaffoldWhite
                  : setPriorityColor(priorityList[value]),
            ),
          ),
        ),
      ),
    );
  }

  setPriorityColor(String value) {
    if (value == "Low") {
      return TodoColors.lightGreen;
    } else if (value == "Medium") {
      return TodoColors.chocolate;
    } else if (value == "High") {
      return TodoColors.massiveRed;
    } else
      return TodoColors.blueAqua;
  }

  Widget _buildCatagoriesPicker(BuildContext context) {
    return Column(children: [
      ...List.generate(
        catagories.length ~/ 3,
        (index) {
          int startIndex = index * 3;
          return Padding(
            padding: EdgeInsets.only(bottom: startIndex == 6 ? 0 : 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (index) {
                  index += startIndex;
                  String category = catagories[index]["name"];
                  return GestureDetector(
                    onTap: () {
                      setState(
                          () => _categoryItems[index] = !_categoryItems[index]);
                    },
                    child: AnimatedContainer(
                      height: 45,
                      width: (MediaQuery.of(context).size.width - 50) / 3,
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _categoryItems[index] == false
                              ? Color(
                                  int.parse(
                                    colors[indexColor],
                                  ),
                                )
                              : TodoColors.scaffoldWhite,
                          width: 1,
                        ),
                        color: _categoryItems[index]
                            ? Color(
                                int.parse(
                                  colors[indexColor],
                                ),
                              )
                            : TodoColors.scaffoldWhite,
                      ),
                      padding: paddingCategory(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            catagories[index]["iconData"],
                            size: iconSize(),
                            color: _categoryItems[index] == false
                                ? Color(
                                    int.parse(
                                      colors[indexColor],
                                    ),
                                  )
                                : TodoColors.scaffoldWhite,
                          ),
                          Text(
                            '${category.tr}',
                            style: TextStyle(
                              fontFamily: 'Source_Sans_Pro',
                              fontSize: fontSize(),
                              color: _categoryItems[index] == false
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
                  );
                },
              ),
            ),
          );
        },
      ),
    ]);
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
                  'Warning:'.tr,
                  style: TextStyle(
                    fontFamily: 'Alata',
                    fontSize: 30,
                    decorationStyle: TextDecorationStyle.double,
                    color: Colors.yellow[900],
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  'Please fill in the blank.'.tr,
                  style: NotemonTextStyle.kTitleStyle,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colors.parseColor(indexColor),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel'.tr,
                          style: NotemonTextStyle.kTitleStyle
                              .copyWith(color: Colors.white),
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
              color: colors.parseColor(indexColor).withOpacity(0.05),
              blurRadius: 5,
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
                style: NotemonTextStyle.kNormalSuperSmallStyle,
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

  Widget _buildColorPicker() {
    return SizedBox(
      height: (MediaQuery.of(context).size.width - 60) / 3 + 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              colors.length ~/ 2,
              (index) {
                if (indexColor == index) {
                  return _colorTile(
                    index,
                    child: Icon(Icons.check, color: Colors.white),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      setState(() => indexColor = index);
                    },
                    child: _colorTile(index),
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              colors.length ~/ 2,
              (newIndex) {
                int index = newIndex + colors.length ~/ 2;
                if (indexColor == index) {
                  return _colorTile(
                    index,
                    child: Icon(Icons.check, color: Colors.white),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      setState(() => indexColor = index);
                    },
                    child: _colorTile(index),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _colorTile(int index, {Widget child}) {
    return Container(
      height: (MediaQuery.of(context).size.width - 60) / 6,
      width: (MediaQuery.of(context).size.width - 60) / 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(
          int.parse(colors[index]),
        ),
      ),
      child: child ?? null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _achieveController.close();
    _achieveTextController.dispose();
    _taskNameTextController.dispose();
  }
}
