import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/todo_screen/todo_screen.dart';
import 'package:gottask/utils/utils.dart';

class TodoTile extends StatefulWidget {
  final Todo todo;
  const TodoTile({
    Key key,
    this.todo,
  }) : super(key: key);

  @override
  _TodoTileState createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> with BlocCreator, FilterMixin {
  bool _isChecked;
  bool _isDone = false;
  TodoBloc _todoBloc;
  StarBloc _starBloc;
  FirebaseApi _repository;
  Todo _currentTodo;

  @override
  void initState() {
    super.initState();
    if (widget.todo.state == "done")
      _isChecked = true;
    else
      _isChecked = false;
  }

  @override
  Widget build(BuildContext context) {
    _todoBloc = findBloc<TodoBloc>();
    _starBloc = findBloc<StarBloc>();
    _repository = findBloc<FirebaseApi>();
    _currentTodo = widget.todo;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        right: 10,
        left: 10,
      ),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        fastThreshold: 20,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: Color(int.parse(colors[widget.todo.color]))
                    .withOpacity(0.05),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (_isDone != true) {
                Get.to(TodoScreen(todo: _currentTodo));
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    if (_isDone != true) {
                      setState(() => _isChecked = !_isChecked);
                      _currentTodo = _currentTodo.copyWith(
                          state: _isChecked ? "done" : "notDone");
                      _todoBloc.add(EditTodoEvent(todo: _currentTodo));
                      if (await checkConnection()) {
                        await _repository.firebase
                            .updateTodoToFirebase(_currentTodo);
                      }
                    }
                  },
                  child: _isChecked
                      ? Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color:
                                  Color(int.parse(colors[widget.todo.color])),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    Color(int.parse(colors[widget.todo.color])),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Text(
                    widget.todo.content,
                    overflow: TextOverflow.ellipsis,
                    style: NotemonTextStyle.kNormalSmallStyle.copyWith(
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: _isChecked
                          ? Color(int.parse(colors[widget.todo.color]))
                          : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    priorityList[widget.todo.priority.index].tr,
                    style: NotemonTextStyle.kNormalStyle.copyWith(
                      color: setPriorityColor(
                          priorityList[widget.todo.priority.index]),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 2,
                  color: Color(int.parse(colors[widget.todo.color])),
                ),
              ],
            ),
          ),
        ),
        secondaryActions: <Widget>[
          SlideAction(
            onTap: () async {
              if (_isChecked == false) {
                Future.delayed(Duration(milliseconds: 300), () async {
                  setState(() => _isChecked = !_isChecked);
                  _currentTodo = _currentTodo.copyWith(
                      state: _isChecked ? "done" : "notDone");
                  _todoBloc.add(EditTodoEvent(todo: _currentTodo));
                  if (await checkConnection()) {
                    await _repository.firebase
                        .updateTodoToFirebase(_currentTodo);
                  }
                });
              } else if (_isChecked == true) {
                _isDone = true;
                Future.delayed(Duration(milliseconds: 350), () async {
                  _todoBloc.add(DeleteTodoEvent(
                    todo: widget.todo,
                    addDeleteKey: true,
                  ));
                  if (await checkConnection()) {
                    await _repository.firebase
                        .deleteTodoOnFirebase(_currentTodo);
                  }
                  _starBloc.add(AddStarEvent(point: 1));
                });
              }
            },
            closeOnTap: true,
            decoration: BoxDecoration(
              color: _isChecked == false
                  ? Colors.lightGreen
                  : Color(int.parse(colors[widget.todo.color])),
              borderRadius: _isChecked
                  ? BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(int.parse(colors[widget.todo.color]))
                      .withOpacity(0.05),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Icon(
                      _isChecked == false
                          ? MaterialCommunityIcons.check
                          : Icons.check_circle,
                      size: 30,
                      color: Colors.white,
                    ),
                    Text(
                      _isChecked == false ? 'Check'.tr : 'Done'.tr,
                      style: NotemonTextStyle.kTinySmallStyle
                          .copyWith(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isChecked == false)
            SlideAction(
              onTap: () async {
                _isDone = true;
                bool connection = await checkConnection();
                Future.delayed(Duration(milliseconds: 350), () async {
                  _todoBloc.add(DeleteTodoEvent(
                    todo: widget.todo,
                    addDeleteKey: true,
                  ));
                  if (connection) {
                    _repository.firebase.deleteTodoOnFirebase(widget.todo);
                  }
                });
              },
              closeOnTap: true,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color(int.parse(colors[widget.todo.color]))
                        .withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Icon(
                        MaterialIcons.delete_forever,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        'Delete'.tr,
                        style: NotemonTextStyle.kTinySmallStyle
                            .copyWith(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
