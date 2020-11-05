import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gottask/utils/utils.dart';

enum ActionType { task, todo }

class AddDialog extends StatelessWidget {
  final Offset offset;
  final Function() onTemplateAdd;
  final Function() onCustomAdd;

  const AddDialog(
      {Key key, this.onTemplateAdd, this.onCustomAdd, @required this.offset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: offset.dy + 5.0,
          child: SizedBox(
            width: Get.width,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _optionTile(
                    icon: Icon(
                      Icons.file_present,
                      color: Colors.white,
                      size: 15,
                    ),
                    func: onTemplateAdd,
                    message: "template",
                    title: "Template",
                    color: TodoColors.chocolate,
                  ),
                  SizedBox(width: 5),
                  _optionTile(
                    icon: Icon(
                      Icons.dashboard_customize,
                      color: Colors.white,
                      size: 15,
                    ),
                    func: onCustomAdd,
                    message: "custom",
                    title: "Custom",
                    color: TodoColors.spiritBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _optionTile({
    String title,
    String message,
    Icon icon,
    Function() func,
    Color color,
  }) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Get.back();

          Future.delayed(Duration(milliseconds: 300), func);
        },
        child: Container(
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TodoColors.scaffoldWhite,
                Color.lerp(Colors.white, TodoColors.lightGreen, 0.1)
                    .withOpacity(1),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "   $title   ",
                style: NotemonTextStyle.kNormalSmallStyle.copyWith(
                  fontSize: 13,
                  color: TodoColors.blueMoon,
                ),
              ),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Tooltip(
                  message: "Add $message",
                  child: icon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
