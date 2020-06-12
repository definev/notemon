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

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with BlocCreator, FilterMixin {
  int indexColor = 0;
  List<bool> _catagoryItems =
      List.generate(catagories.length, (index) => false);
  Duration timer = const Duration(hours: 0, minutes: 0);

  final List<String> _achieveLists = [];
  final List<bool> _isDoneAchieveLists = [];
  PriorityState _priority = PriorityState.Low;

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
                  _repository.updateTaskToFirebase(_task);
                }
                Navigator.pop(context);
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
                _buildTitle('Catagory'),
                _buildCatagoriesPicker(context),
                _buildTitle('Achievment'),
                _buildAchievment(context),
                _buildListAchievment(),
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

  Padding _buildListAchievment() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
      padding: const EdgeInsets.only(
        top: 5,
      ),
      child: SizedBox(
        height: 50,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    labelText: 'Achieve goal',
                    labelStyle: kNormalStyle.copyWith(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  controller: _achieveTextController,
                  style: kNormalStyle.copyWith(
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
                color: Color(int.parse(colors[indexColor])),
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
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        title,
        style: kNormalStyle.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildRename() {
    return AnimatedContainer(
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
    );
  }

  Widget _buildPriorityPicker() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
      ),
      child: Row(
        children: [
          _priorityTile(PriorityState.High.index),
          SizedBox(width: 10),
          _priorityTile(PriorityState.Medium.index),
          SizedBox(width: 10),
          _priorityTile(PriorityState.Low.index),
        ],
      ),
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
            priorityList[value],
            style: kNormalStyle.copyWith(
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
      ),
      child: Wrap(
        direction: Axis.horizontal,
        children: List.generate(
          catagories.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _catagoryItems[index] = !_catagoryItems[index];
              });
            },
            child: AnimatedContainer(
              height: 45,
              width: (MediaQuery.of(context).size.width - 50) / 3,
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
                  width: 1,
                ),
                color: _catagoryItems[index]
                    ? Color(
                        int.parse(
                          colors[indexColor],
                        ),
                      )
                    : TodoColors.scaffoldWhite,
              ),
              padding: paddingCatagory(),
              margin: marginCatagory(index),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    catagories[index]["iconData"],
                    size: iconSize(),
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
                      fontSize: fontSize(),
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

  Widget _buildColorPicker() => SizedBox(
        height: 50 * 2.0 + 28,
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
      );

  @override
  void dispose() {
    super.dispose();
    _achieveController.close();
    _achieveTextController.dispose();
    _taskNameTextController.dispose();
  }
}
