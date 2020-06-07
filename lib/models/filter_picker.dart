import 'package:flutter/material.dart';
import 'package:gottask/utils/utils.dart';

class FilterPicker extends StatefulWidget {
  final List<bool> initCatagory;
  final Function(List<bool> catagories, String priority) onCompeleted;

  const FilterPicker(
      {Key key, @required this.onCompeleted, @required this.initCatagory})
      : super(key: key);

  @override
  _FilterPickerState createState() => _FilterPickerState();
}

class _FilterPickerState extends State<FilterPicker> {
  List<bool> _catagories = [];
  String priority = "";
  Color currentColor = TodoColors.blueAqua;

  Widget _buildCatagoriesPicker() => SizedBox(
        height: 50,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: List.generate(
              catagories.length,
              (index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _catagories[index] = !_catagories[index];
                      });
                    },
                    child: AnimatedContainer(
                      height: 50,
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _catagories[index] == false
                              ? currentColor
                              : TodoColors.scaffoldWhite,
                        ),
                        color: _catagories[index]
                            ? currentColor
                            : TodoColors.scaffoldWhite,
                      ),
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(
                        left: 20,
                        bottom: 5,
                        right: 10,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              catagories[index]['iconData'],
                              size: 15,
                              color: _catagories[index] == false
                                  ? currentColor
                                  : TodoColors.scaffoldWhite,
                            ),
                            Text(
                              ' ${catagories[index]["name"]}',
                              style: kNormalSuperSmallStyle.copyWith(
                                color: _catagories[index] == false
                                    ? currentColor
                                    : TodoColors.scaffoldWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (index == catagories.length - 1) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _catagories[index] = !_catagories[index];
                      });
                    },
                    child: AnimatedContainer(
                      height: 50,
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _catagories[index] == false
                              ? currentColor
                              : TodoColors.scaffoldWhite,
                        ),
                        color: _catagories[index]
                            ? currentColor
                            : TodoColors.scaffoldWhite,
                      ),
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(
                        bottom: 5,
                        right: 20,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              catagories[index]["iconData"],
                              size: 15,
                              color: _catagories[index] == false
                                  ? currentColor
                                  : TodoColors.scaffoldWhite,
                            ),
                            Text(
                              ' ${catagories[index]["name"]}',
                              style: kNormalSuperSmallStyle.copyWith(
                                color: _catagories[index] == false
                                    ? currentColor
                                    : TodoColors.scaffoldWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _catagories[index] = !_catagories[index];
                    });
                  },
                  child: AnimatedContainer(
                    height: 50,
                    width: (MediaQuery.of(context).size.width - 60) / 3,
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _catagories[index] == false
                            ? currentColor
                            : TodoColors.scaffoldWhite,
                      ),
                      color: _catagories[index]
                          ? currentColor
                          : TodoColors.scaffoldWhite,
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(
                      bottom: 5,
                      right: 10,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            catagories[index]["iconData"],
                            size: 15,
                            color: _catagories[index] == false
                                ? currentColor
                                : TodoColors.scaffoldWhite,
                          ),
                          Text(
                            ' ${catagories[index]["name"]}',
                            style: kNormalSuperSmallStyle.copyWith(
                              color: _catagories[index] == false
                                  ? currentColor
                                  : TodoColors.scaffoldWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

  _buildPriority() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  if (priority != 'High') {
                    priority = 'High';
                    currentColor = TodoColors.massiveRed;
                  } else {
                    priority = '';
                    currentColor = TodoColors.blueAqua;
                  }
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: priority != 'High'
                      ? TodoColors.scaffoldWhite
                      : TodoColors.massiveRed,
                  border: Border.all(
                    color: priority == 'High'
                        ? TodoColors.scaffoldWhite
                        : TodoColors.massiveRed,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'High',
                    style: kNormalStyle.copyWith(
                      color: priority == 'High'
                          ? TodoColors.scaffoldWhite
                          : TodoColors.massiveRed,
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
                setState(() {
                  if (priority != 'Medium') {
                    priority = 'Medium';
                    currentColor = TodoColors.lightOrange;
                  } else {
                    priority = '';
                    currentColor = TodoColors.blueAqua;
                  }
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: priority != 'Medium'
                      ? TodoColors.scaffoldWhite
                      : TodoColors.lightOrange,
                  border: Border.all(
                    color: priority == 'Medium'
                        ? TodoColors.scaffoldWhite
                        : TodoColors.lightOrange,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Medium',
                    style: kNormalStyle.copyWith(
                      color: priority == 'Medium'
                          ? TodoColors.scaffoldWhite
                          : TodoColors.lightOrange,
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
                setState(() {
                  if (priority != 'Low') {
                    priority = 'Low';
                    currentColor = TodoColors.lightGreen;
                  } else {
                    priority = '';
                    currentColor = TodoColors.blueAqua;
                  }
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: priority != 'Low'
                      ? TodoColors.scaffoldWhite
                      : TodoColors.lightGreen,
                  border: Border.all(
                    color: priority == 'Low'
                        ? TodoColors.scaffoldWhite
                        : TodoColors.lightGreen,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Low',
                    style: kNormalStyle.copyWith(
                      color: priority == 'Low'
                          ? TodoColors.scaffoldWhite
                          : TodoColors.lightGreen,
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

  @override
  void initState() {
    super.initState();
    _catagories = widget.initCatagory;
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Filter',
                  style: kBigTitleStyle.copyWith(
                    fontFamily: 'Source_Sans_Pro',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Text(
                'Catagories',
                style: kMediumStyle,
              ),
            ),
            _buildCatagoriesPicker(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Text(
                'Priority',
                style: kMediumStyle,
              ),
            ),
            _buildPriority(),
            Padding(
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
                        height: 50,
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
                        height: 50,
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
            ),
          ],
        ),
      ),
    );
  }
}
