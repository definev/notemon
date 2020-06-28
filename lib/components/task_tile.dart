import 'package:flutter/material.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/screens/task_screen/task_export.dart';
import 'package:gottask/utils/utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final bool removeAds;

  const TaskTile({Key key, this.task, @required this.removeAds})
      : super(key: key);

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with FilterMixin {
  int maxTimer;
  int starValue;

  @override
  void initState() {
    super.initState();

    var _rawTimer = widget.task.timer.split(':');
    var _rawSecond = _rawTimer[2].split('.');
    maxTimer = int.parse(_rawTimer[0]) * 3600 +
        int.parse(_rawTimer[1]) * 60 +
        int.parse(_rawSecond[0]);
    starValue = maxTimer ~/ 60;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskScreen(
              task: widget.task,
              removeAds: widget.removeAds,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 14.5,
        ),
        height: kListViewHeight,
        width: kListViewHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Color(int.parse(colors[widget.task.color])),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color:
                  Color(int.parse(colors[widget.task.color])).withOpacity(0.2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Container(
                    height: 34,
                    width: 55.0131556175,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 15,
                            width: 1.5,
                            color: setPriorityColor(
                                priorityList[widget.task.priority.index]),
                          ),
                          Text(
                            shortPriorityList[widget.task.priority.index],
                            style: kNormalStyle.copyWith(
                              fontFamily: "Source_Sans_Pro",
                              color: setPriorityColor(
                                  priorityList[widget.task.priority.index]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '$starValue ',
                      style:
                          kNormalSuperSmallStyle.copyWith(color: Colors.white),
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
              widget.task.taskName,
              style: kBigTitleStyle.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LinearPercentIndicator(
                  padding: const EdgeInsets.only(right: 0, top: 10, bottom: 10),
                  lineHeight: 4.5,
                  progressColor: Colors.white,
                  backgroundColor: Colors.black54,
                  percent: widget.task.percent.toDouble() / maxTimer,
                ),
                const SizedBox(height: 12),
                Text(
                  durationFormat(widget.task.completeTimer),
                  style: kNormalSmallStyle.copyWith(
                      color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
