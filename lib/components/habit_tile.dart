import 'package:flutter/material.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/models/habit.dart';
import 'package:gottask/screens/habit_screen/habit_screen.dart';
import 'package:icons_helper/icons_helper.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;

  const HabitTile({Key key, this.habit}) : super(key: key);

  @override
  _HabitTileState createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  int maxTimer;
  int starValue;

  @override
  void initState() {
    super.initState();

    var _rawTimer = widget.habit.timer.split(':');
    var _rawSecond = _rawTimer[2].split('.');
    maxTimer = int.parse(_rawTimer[0]) * 3600 +
        int.parse(_rawTimer[1]) * 60 +
        int.parse(_rawSecond[0]);
    starValue = maxTimer ~/ 60;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitScreen(habit: widget.habit),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(15),
          height: kListViewHeight,
          width: kListViewHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(
              int.parse(colors[widget.habit.color]),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white.withOpacity(0.35),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        getIconUsingPrefix(
                          name: icons[widget.habit.icon],
                        ),
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '$starValue ',
                        style: TextStyle(
                          fontFamily: 'Alata',
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Image.asset(
                        'assets/png/star.png',
                        height: 14,
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                widget.habit.habitName,
                style: TextStyle(
                  fontFamily: 'Alata',
                  fontSize: 25,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LinearPercentIndicator(
                    padding: const EdgeInsets.only(right: 0, top: 10),
                    lineHeight: 4.5,
                    progressColor: Colors.white,
                    backgroundColor: Colors.black54,
                    percent: widget.habit.percent.toDouble() / maxTimer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    durationFormat(widget.habit.completeTimer),
                    style: TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
