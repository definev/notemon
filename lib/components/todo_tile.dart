import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gottask/bloc/do_del_done_todo/bloc/do_del_done_todo_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/todo/bloc/todo_bloc.dart';
import 'package:gottask/models/do_del_done_todo.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/screens/todo_screen/todo_screen.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';

class TodoTile extends StatefulWidget {
  final Todo task;
  final int index;
  const TodoTile({
    Key key,
    this.task,
    @required this.index,
  }) : super(key: key);

  @override
  _TodoTileState createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> with BlocCreator {
  bool _isChecked;
  bool _isDone = false;
  TodoBloc _todoBloc;
  DoDelDoneTodoBloc _doDelDoneTodoBloc;
  StarBloc _starBloc;
  Todo _currentTask;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.task.isDone;
  }

  @override
  Widget build(BuildContext context) {
    _todoBloc = findBloc<TodoBloc>();
    _doDelDoneTodoBloc = findBloc<DoDelDoneTodoBloc>();
    _starBloc = findBloc<StarBloc>();
    _currentTask = widget.task;

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
          ),
          child: InkWell(
            onTap: () {
              if (_isDone != true)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoScreen(todo: _currentTask),
                  ),
                );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (_isDone != true) {
                      setState(() => _isChecked = !_isChecked);
                      _currentTask = _currentTask.copyWith(isDone: _isChecked);
                      _todoBloc.add(EditTodoEvent(todo: _currentTask));
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
                                  Color(int.parse(colors[widget.task.color])),
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
                                color: Color(
                                  int.parse(colors[widget.task.color]),
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Text(
                    widget.task.content,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 15,
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: _isChecked
                          ? Color(int.parse(colors[widget.task.color]))
                          : Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  width: 2,
                  color: Color(int.parse(colors[widget.task.color])),
                ),
              ],
            ),
          ),
        ),
        secondaryActions: <Widget>[
          SlideAction(
            closeOnTap: true,
            decoration: BoxDecoration(
              color: _isChecked == false
                  ? Colors.lightGreen
                  : Color(int.parse(colors[widget.task.color])),
              borderRadius: _isChecked
                  ? BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  : null,
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
                      _isChecked == false ? 'Check' : 'Done',
                      style: TextStyle(
                        fontFamily: 'Alata',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              if (_isChecked == false) {
                Future.delayed(Duration(milliseconds: 300), () {
                  setState(() => _isChecked = !_isChecked);
                  _currentTask =
                      _currentTask.copyWith(isDone: !_currentTask.isDone);
                  _todoBloc.add(
                    EditTodoEvent(todo: _currentTask),
                  );
                });
              } else if (_isChecked == true) {
                _isDone = true;
                Future.delayed(Duration(milliseconds: 350), () async {
                  await saveDoneTask();

                  int doTodo = await onDoingTask();
                  int delTodo = await readDeleteTask();
                  int doneTodo = await readDoneTask();
                  print('');
                  _doDelDoneTodoBloc.add(
                    UpdateDoDelDoneTodoEvent(
                      DoDelDoneTodo(
                        id: 1,
                        doTodo: doTodo,
                        delTodo: delTodo,
                        doneTodo: doneTodo,
                      ),
                    ),
                  );
                  _todoBloc.add(DeleteTodoEvent(todo: widget.task));
                  _starBloc.add(AddStarEvent(point: 1));
                });
              }
            },
          ),
          if (_isChecked == false)
            SlideAction(
              onTap: () async {
                _isDone = true;
                Future.delayed(Duration(milliseconds: 350), () async {
                  await saveDoneTask();

                  int doTodo = await onDoingTask();
                  int delTodo = await readDeleteTask();
                  int doneTodo = await readDoneTask();

                  _doDelDoneTodoBloc.add(
                    UpdateDoDelDoneTodoEvent(
                      DoDelDoneTodo(
                        id: 1,
                        doTodo: doTodo,
                        delTodo: delTodo,
                        doneTodo: doneTodo,
                      ),
                    ),
                  );
                  _todoBloc.add(DeleteTodoEvent(todo: widget.task));
                  _starBloc.add(AddStarEvent(point: 1));
                });
              },
              closeOnTap: true,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
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
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Alata',
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
