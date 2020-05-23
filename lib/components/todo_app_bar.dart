import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/screens/todo_screen/add_todo_screen.dart';
import 'package:gottask/utils/utils.dart';

class TodoAppBar extends StatefulWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onChartPressed;
  final bool addButton;
  TodoAppBar({
    this.onChartPressed,
    this.onHomePressed,
    this.addButton,
  });
  @override
  _TodoAppBarState createState() => _TodoAppBarState();
}

class _TodoAppBarState extends State<TodoAppBar> {
  @override
  Widget build(BuildContext context) {
    void _modalBottomSheetMenu() {
      showModalBottomSheet(
          context: context,
          builder: (_) => AddTodoScreen());
    }

    return BottomAppBar(
      elevation: 0,
      color: Colors.transparent,
      child: Material(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        elevation: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(6),
              child: InkWell(
                onTap: () {
                  _modalBottomSheetMenu();
                },
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Material(
                      borderRadius: BorderRadius.circular(49),
                      color: TodoColors.deepPurple,
                      child: Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Icon(
                          Ionicons.ios_add,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
