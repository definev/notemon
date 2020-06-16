import 'package:flutter/material.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/utils/utils.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({Key key, this.task}) : super(key: key);
  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> with FilterMixin {
  TextEditingController _taskEditting = TextEditingController();

  PriorityState _priority;
  List<bool> _catagoryItems;
  int indexColor = 0;

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 5, top: 2),
      child: Text(
        title,
        style: kNormalStyle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTaskNameTextField() => AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(int.parse(colors[indexColor])),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _taskEditting,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: 'Task name',
            labelStyle: kNormalStyle.copyWith(color: Colors.grey),
            focusColor: TodoColors.lightOrange,
            border: InputBorder.none,
          ),
        ),
      );

  Widget _buildEditTaskButton(BuildContext context) => GestureDetector(
        onTap: () async {
          Navigator.pop(
              context,
              widget.task.copyWith(
                catagories: _catagoryItems,
                priority: _priority,
                color: indexColor,
                taskName: _taskEditting.text == null || _taskEditting.text == ""
                    ? widget.task.taskName
                    : _taskEditting.text,
              ));
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
                Text(
                  ' Edit task',
                  style: kNormalStyle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          color: Color(int.parse(colors[indexColor])),
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
    return Wrap(
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
    );
  }

  @override
  void initState() {
    super.initState();
    _priority = widget.task.priority;
    _catagoryItems = widget.task.catagories;
    indexColor = widget.task.color;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(accentColor: Color(int.parse(colors[indexColor]))),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: _buildEditTaskButton(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTaskNameTextField(),
                  _buildTitle('Color'),
                  _buildColorPicker(),
                  _buildTitle('Priority'),
                  _buildPriorityPicker(),
                  _buildTitle('Catagory'),
                  _buildCatagoriesPicker(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
