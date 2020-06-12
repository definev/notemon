import 'package:flutter/material.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/utils/utils.dart';

class FilterPicker extends StatefulWidget {
  final List<bool> initCatagory;
  final PriorityState priority;
  final String nameFilter;
  final Function(List<bool> catagories, PriorityState priority) onCompeleted;

  const FilterPicker({
    Key key,
    @required this.onCompeleted,
    @required this.initCatagory,
    @required this.priority,
    @required this.nameFilter,
  }) : super(key: key);

  @override
  _FilterPickerState createState() => _FilterPickerState();
}

class _FilterPickerState extends State<FilterPicker>
    with BlocCreator, FilterMixin {
  List<bool> _catagories = [];
  PriorityState priority = PriorityState.Low;
  Color currentColor = TodoColors.blueAqua;

  Widget _buildCatagoryPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Wrap(
        direction: Axis.horizontal,
        children: List.generate(
          catagories.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _catagories[index] = !_catagories[index];
              });
            },
            child: AnimatedContainer(
              height: 45,
              width: (MediaQuery.of(context).size.width - 60) / 3,
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _catagories[index] == false
                      ? setPriorityColor(priorityList[priority.index])
                      : TodoColors.scaffoldWhite,
                  width: 1,
                ),
                color: _catagories[index]
                    ? setPriorityColor(priorityList[priority.index])
                    : TodoColors.scaffoldWhite,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: marginCatagory(index),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    catagories[index]["iconData"],
                    size: iconSize(),
                    color: _catagories[index] == false
                        ? setPriorityColor(priorityList[priority.index])
                        : TodoColors.scaffoldWhite,
                  ),
                  Text(
                    '${catagories[index]["name"]}',
                    style: TextStyle(
                      fontFamily: 'Source_Sans_Pro',
                      fontSize: fontSize(),
                      fontWeight: FontWeight.w500,
                      color: _catagories[index] == false
                          ? setPriorityColor(priorityList[priority.index])
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

  _buildPriority() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _priorityTile(PriorityState.High),
          SizedBox(width: 10),
          _priorityTile(PriorityState.Medium),
          SizedBox(width: 10),
          _priorityTile(PriorityState.Low),
          SizedBox(width: 10),
          _priorityTile(PriorityState.All),
        ],
      ),
    );
  }

  Widget _priorityTile(PriorityState value) {
    return InkWell(
      onTap: () {
        setState(() {
          if (priority != value) {
            priority = value;
          } else {
            priority = PriorityState.All;
          }
          currentColor = setPriorityColor(priorityList[priority.index]);
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 45,
        width: (MediaQuery.of(context).size.width - 70) / 4,
        decoration: BoxDecoration(
          color: priority != value
              ? TodoColors.scaffoldWhite
              : setPriorityColor(priorityList[value.index]),
          border: Border.all(
            color: priority == value
                ? TodoColors.scaffoldWhite
                : setPriorityColor(priorityList[value.index]),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            priorityList[value.index],
            style: kNormalStyle.copyWith(
              color: priority == value
                  ? TodoColors.scaffoldWhite
                  : setPriorityColor(priorityList[value.index]),
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

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
        left: 20,
        right: 20,
      ),
      child: Text(
        text,
        style: kMediumStyle,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _catagories = widget.initCatagory;
    priority = widget.priority;
    currentColor = setPriorityColor(priorityList[priority.index]);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: TodoColors.scaffoldWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            _buildTitle('Catagory'),
            _buildCatagoryPicker(context),
            _buildTitle('Priority'),
            _buildPriority(),
            _confirmButton(context),
          ],
        ),
      ),
    );
  }

  Padding _confirmButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: kNormalStyle.copyWith(
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () {
                if (widget.onCompeleted != null) {
                  widget.onCompeleted(_catagories, priority);
                  print(_catagories);
                }
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 45,
                decoration: BoxDecoration(
                  color: TodoColors.deepPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Ok',
                    style: kNormalStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.nameFilter} filter',
                style: kBigTitleStyle.copyWith(
                  fontFamily: 'Tomorrow',
                  fontSize: 30,
                ),
              ),
              (_catagories.contains(true))
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _catagories = List.generate(
                              catagories.length, (index) => false);
                          priority = PriorityState.All;
                        });
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 60) / 3,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Clear",
                            style: kNormalStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        Divider(
          color: Colors.black45,
          height: 0.8,
        ),
      ],
    );
  }
}
