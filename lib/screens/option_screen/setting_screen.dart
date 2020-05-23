import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/hand_side/bloc/hand_side_bloc.dart';
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
  bool _isInit = false;

  List<bool> _leftOrRight;

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
                      style: TextStyle(
                        fontSize: 20,
                      ),
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
                  _auth.signOut().then((value) async {
                    updateLoginState(false);
                    Navigator.pushNamed(context, '/signIn');
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                      fontFamily: 'Alata',
                      color: Colors.red,
                      fontSize: 18,
                    ),
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
