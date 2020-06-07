import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/database/database.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';
import 'package:gottask/screens/option_screen/about_me_screen.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  final BuildContext ctx;

  const SettingScreen({Key key, @required this.ctx}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin, BlocCreator {
  AnimationController animationController;
  Animation animation;

  HandSide _handSide;
  HandSideBloc _handsideBloc;
  AllPokemonBloc _allPokemonBloc;
  TaskBloc _taskBloc;
  TodoBloc _todoBloc;
  FavouritePokemonBloc _favouritePokemonBloc;
  StarBloc _starBloc;
  bool _isInit = false;

  List<bool> _leftOrRight;

  deleteAll() {
    _allPokemonBloc.pokemonStateList.forEach((state) {
      _allPokemonBloc.add(
        UpdatePokemonStateEvent(
          pokemonState: PokemonState(name: state.name, state: 0),
        ),
      );
    });

    List<Todo> _todoList = _todoBloc.todoList;
    _todoList.forEach((todo) =>
        _todoBloc.add(DeleteTodoEvent(todo: todo, addDeleteKey: false)));
    List<Task> _taskList = _taskBloc.taskList;
    TodoTable.deleteAllDeleteKey();
    _taskList.forEach((task) =>
        _taskBloc.add(DeleteTaskEvent(task: task, addDeleteKey: false)));
    TaskTable.deleteAllDeleteKey();
    _starBloc.add(SetStarEvent(point: null));
    _favouritePokemonBloc.add(UpdateFavouritePokemonEvent(null));
  }

  initHandSide() async {
    _handSide = await currentHandSide();
    _refreshLeftOrRight();
  }

  _refreshLeftOrRight() {
    setState(() {
      if (_handSide == HandSide.Left)
        _leftOrRight = [true, false];
      else if (_handSide == HandSide.Right) _leftOrRight = [false, true];
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) {
      _handsideBloc = Provider.of<HandSideBloc>(widget.ctx);
      initHandSide();
      _allPokemonBloc = findBloc<AllPokemonBloc>();
      _favouritePokemonBloc = findBloc<FavouritePokemonBloc>();
      _starBloc = findBloc<StarBloc>();
      _todoBloc = findBloc<TodoBloc>();
      _taskBloc = findBloc<TaskBloc>();
      _isInit = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setting',
          style: TextStyle(
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AboutMeScreen(),
              ),
            ),
            icon: Icon(
              Feather.info,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Handside control ',
                      style: kTitleStyle,
                    ),
                    ToggleButtons(
                      isSelected:
                          _leftOrRight != null ? _leftOrRight : [false, false],
                      onPressed: (index) {
                        if (index == 0) {
                          _handSide = HandSide.Left;
                          _refreshLeftOrRight();
                          _handsideBloc
                              .add(HandSideChanged(handSide: _handSide));
                        } else {
                          _handSide = HandSide.Right;
                          _refreshLeftOrRight();
                          _handsideBloc
                              .add(HandSideChanged(handSide: _handSide));
                        }
                      },
                      children: <Widget>[
                        Text('L'),
                        Text('R'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  AuthServices _auth = AuthServices();
                  _auth.signOut().then((_) async {
                    updateLoginState(false);
                    deleteAll();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.popAndPushNamed(context, '/signIn');
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Sign out',
                    style: kMediumStyle.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
