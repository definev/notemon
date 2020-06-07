import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_incall/flutter_incall.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/countdown_clock.dart';
import 'package:gottask/components/parrallel_background.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';
import 'package:icons_helper/icons_helper.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vibration/vibration.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}

class TaskScreen extends StatefulWidget {
  final Task task;
  TaskScreen({this.task});
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with BlocCreator {
  List<String> _achievelists;
  Duration _timer;
  int _percent;
  int _iconIndex;
  int _maxTimer;
  bool _isInit = false;
  List<bool> _isDoneAchieve = [];
  List<bool> _catagoryItems =
      List.generate(catagories.length, (index) => false);

  SlideCountdownClock countdownClock;
  TimerState _timerState = TimerState.PAUSE;

  TaskBloc _taskBloc;
  StarBloc _starBloc;
  FirebaseRepository _repository;
  TextEditingController _achieveTextController = TextEditingController();

  FocusNode myFocusNode;
  IncallManager _incallManager = IncallManager();
  bool isProcess = true;
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();

  InterstitialAd myInterstitial;

  InterstitialAd _interstitialAds() {
    return InterstitialAd(
      adUnitId: interstitialId,
      targetingInfo: targetingInfo,
    );
  }

  _onBackPress() async {
    //Back and update data
    List<String> durTimer = widget.task.timer.split(':');
    List<String> durTimerSecond = durTimer[2].split('.');
    if (_timerState == TimerState.PLAY)
      setState(() {
        _timerState = TimerState.PAUSE;
        countdownClock.onPause = true;
        countdownClock.isPlay = false;
      });
    var _oldTimer = Duration(
      hours: int.parse(durTimer[0]),
      minutes: int.parse(durTimer[1]),
      seconds: int.parse(durTimerSecond[0]),
    );
    Duration _completeTimer = _oldTimer - _timer;
    _taskBloc.add(
      EditTaskEvent(
        task: widget.task.copyWith(
          achieve: _achievelists,
          catagories: _catagoryItems,
          completeTimer: _completeTimer.toString(),
          icon: _iconIndex,
          isDoneAchieve: _isDoneAchieve,
          percent: _percent,
        ),
      ),
    );
    _repository.updateTaskToFirebase(
      widget.task.copyWith(
        achieve: _achievelists,
        catagories: _catagoryItems,
        completeTimer: _completeTimer.toString(),
        icon: _iconIndex,
        isDoneAchieve: _isDoneAchieve,
        percent: _percent,
      ),
    );
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        myInterstitial
          ..load()
          ..show();
      }
    } on SocketException catch (_) {}
    Navigator.pop(context);
    return true;
  }

  IconData _getTimerState() {
    if (_timerState == TimerState.PAUSE)
      return Icons.play_arrow;
    else
      return Icons.pause;
  }

  Widget _widgetInCircle() {
    if (_timerState == TimerState.DONE) {
      return Text(
        'Done!',
        style: TextStyle(
          fontFamily: 'Alata',
          fontSize: 30,
          color: Color(int.parse(colors[widget.task.color])),
        ),
      );
    } else {
      return Icon(
        _getTimerState(),
        color: Color(
          int.parse(
            colors[widget.task.color],
          ),
        ),
        size: 50,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.task.onDoing) {
      FirebaseAdMob.instance.initialize(appId: appId);
      myInterstitial = _interstitialAds();

      myFocusNode = FocusNode();
      _catagoryItems = widget.task.catagories;

      _achievelists = widget.task.achieve;
      List<String> durTimer = widget.task.timer.split(':');
      List<String> durCompleteTimer = widget.task.completeTimer.split(':');
      List<String> durTimerSecond = durTimer[2].split('.');
      List<String> durCompleteTimerSecond = durCompleteTimer[2].split('.');
      _timer = Duration(
        hours: int.parse(durTimer[0]) - int.parse(durCompleteTimer[0]),
        minutes: int.parse(durTimer[1]) - int.parse(durCompleteTimer[1]),
        seconds:
            int.parse(durTimerSecond[0]) - int.parse(durCompleteTimerSecond[0]),
      );
      _maxTimer = int.parse(durTimer[0]) * 3600 +
          int.parse(durTimer[1]) * 60 +
          int.parse(
            durTimerSecond[0],
          );
      _percent = widget.task.percent;
      _iconIndex = widget.task.icon;
      if (_timer == Duration(hours: 0, minutes: 0, seconds: 0)) {
        _timerState = TimerState.DONE;
      }

      if (Platform.isAndroid && _timerState != TimerState.DONE) {
        _incallManager.enableProximitySensor(true);
        _incallManager.turnScreenOff();
        _incallManager.onProximity.stream.listen(
          (proximity) async {
            if (_timerState == TimerState.DONE) {
              _incallManager.turnScreenOn();
              if (audioPlayer.state == AudioPlayerState.PLAYING &&
                  proximity == false) {
                await audioPlayer.stop();
              }
            } else {
              if (proximity == true) {
                if (isProcess == true) {
                  if (await Vibration.hasVibrator()) {
                    Vibration.vibrate(
                      duration: 100,
                      amplitude: 2,
                    );
                  }
                  if (await checkConnection()) {
                    var _oldTimer = Duration(
                      hours: int.parse(durTimer[0]),
                      minutes: int.parse(durTimer[1]),
                      seconds: int.parse(durTimerSecond[0]),
                    );
                    Duration _completeTimer = _oldTimer - _timer;
                    _repository.updateTaskToFirebase(
                      widget.task.copyWith(
                        onDoing: true,
                        achieve: _achievelists,
                        catagories: _catagoryItems,
                        completeTimer: _completeTimer.toString(),
                        icon: _iconIndex,
                        isDoneAchieve: _isDoneAchieve,
                        percent: _percent,
                      ),
                    );
                  }
                  setState(() {
                    isProcess = false;
                    _timerState = TimerState.PLAY;
                    countdownClock.onPause = false;
                  });
                }
              } else {
                if (isProcess == false) {
                  if (await Vibration.hasVibrator()) {
                    Vibration.vibrate(
                      duration: 100,
                      amplitude: 200,
                    );
                  }
                  setState(() {
                    isProcess = true;
                    _timerState = TimerState.PAUSE;
                    countdownClock.onPause = true;
                    var _oldTimer = Duration(
                      hours: int.parse(durTimer[0]),
                      minutes: int.parse(durTimer[1]),
                      seconds: int.parse(durTimerSecond[0]),
                    );
                    Duration _completeTimer = _oldTimer - _timer;
                    _taskBloc.add(
                      EditTaskEvent(
                        task: widget.task.copyWith(
                          achieve: _achievelists,
                          catagories: _catagoryItems,
                          completeTimer: _completeTimer.toString(),
                          icon: _iconIndex,
                          isDoneAchieve: _isDoneAchieve,
                          percent: _percent,
                        ),
                      ),
                    );
                    _repository.updateTaskToFirebase(
                      widget.task.copyWith(
                        onDoing: false,
                        achieve: _achievelists,
                        catagories: _catagoryItems,
                        completeTimer: _completeTimer.toString(),
                        icon: _iconIndex,
                        isDoneAchieve: _isDoneAchieve,
                        percent: _percent,
                      ),
                    );
                  });
                  if (audioPlayer.state == AudioPlayerState.PLAYING) {
                    await audioPlayer.stop();
                  }
                }
              }
            }
          },
        );
      }

      countdownClock = SlideCountdownClock(
        duration: Duration(
          hours: _timer.inHours,
          minutes: _timer.inMinutes.remainder(60),
          seconds: _timer.inSeconds.remainder(60),
        ),
        onChanged: (duration) {
          _timer = duration;
          setState(() {
            _percent++;
          });
        },
        onDone: () async {
          audioPlayer = await audioCache.loop(
            audioFile['Caught_Pokemon'],
          );
          var maxTime = Duration(
            hours: int.parse(durTimer[0]),
            minutes: int.parse(durTimer[1]),
            seconds: int.parse(durTimerSecond[0]),
          );

          setState(() {
            _timerState = TimerState.DONE;
          });
          int pointGet = maxTime.inMinutes;
          _starBloc.add(AddStarEvent(point: pointGet));
        },
        separator: ':',
        textStyle: TextStyle(
          fontFamily: 'ABeeZee',
          letterSpacing: 1,
          fontSize: 40,
        ),
      );
      _isDoneAchieve = widget.task.isDoneAchieve;
    }
  }

  @override
  void dispose() {
    if (myFocusNode != null) myFocusNode.dispose();
    _incallManager.enableProximitySensor(false);
    _incallManager.turnScreenOn();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) {
      _taskBloc = findBloc<TaskBloc>();
      _starBloc = findBloc<StarBloc>();
      _repository = findBloc<FirebaseRepository>();
      _isInit = true;
    }

    return widget.task.onDoing == false
        ? _bodyOnDoingFalse(context)
        : _bodyOnDoingTrue();
  }

  Theme _bodyOnDoingFalse(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: Color(
          int.parse(
            colors[widget.task.color],
          ),
        ),
      ),
      child: Scaffold(
        appBar: _appBar(context),
        body: WillPopScope(
          onWillPop: () => _onBackPress(),
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _clockWheel(context),
                  _buildCatagories(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyOnDoingTrue() {
    return Container(
      color: Color(0xFF5e5d96),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ParrallelBackground(
              child: Image.asset(
                'assets/png/abstract.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Material(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "Doing in another device,\n",
                        style: kBigTitleStyle.copyWith(
                            fontFamily: 'Source_Sans_Pro',
                            color: Colors.white,
                            fontSize: 35),
                      ),
                      Text(
                        "Don't distract! 😊",
                        style: kBigTitleStyle.copyWith(
                            fontFamily: 'Source_Sans_Pro',
                            color: Colors.white,
                            fontSize: 35),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: TodoColors.deepPurple,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clockWheel(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 185,
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          Text(
            '${widget.task.taskName}',
            style: TextStyle(
              fontFamily: 'Alata',
              fontSize: MediaQuery.of(context).size.width / 25,
            ),
          ),
          countdownClock,
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  animationEnabled: true,
                  angleRange: 360,
                  startAngle: 270,
                  customWidths: CustomSliderWidths(
                    progressBarWidth: 8,
                    handlerSize: 0,
                    shadowWidth: 0,
                  ),
                  customColors: CustomSliderColors(
                    dotColor: Color(int.parse(colors[widget.task.color])),
                    progressBarColor:
                        Color(int.parse(colors[widget.task.color])),
                    trackColor: Colors.white,
                  ),
                  size: (MediaQuery.of(context).size.height - 24) / 3.5,
                ),
                initialValue: _percent.toDouble(),
                min: 0,
                max: _maxTimer.toDouble(),
                innerWidget: (percentage) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        if (Platform.isIOS) {
                          setState(() {
                            if (_timerState == TimerState.PLAY) {
                              _timerState = TimerState.PAUSE;
                              countdownClock.onPause = !countdownClock.onPause;
                            } else if (_timerState == TimerState.PAUSE) {
                              _timerState = TimerState.PLAY;
                              countdownClock.onPause = !countdownClock.onPause;
                            }
                          });
                        }
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.height - 24) / 3.5 -
                            20,
                        height:
                            (MediaQuery.of(context).size.height - 24) / 3.5 -
                                20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(160),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: _widgetInCircle(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (_achievelists.length != 0)
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: _achievelists.length + 1,
                itemBuilder: (context, index) {
                  if (index < _achievelists.length)
                    return _buildAchieveTile(index);
                  else {
                    return _buildAddAchieve();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Doing task',
        style: TextStyle(
          fontFamily: 'Montserrat',
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(int.parse(colors[widget.task.color])),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          _onBackPress();
        },
      ),
      actions: <Widget>[
        _timerState != TimerState.DONE
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _buildDeleteCheckDialog(context);
                },
              )
            : IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {
                  _taskBloc.add(
                      DeleteTaskEvent(task: widget.task, addDeleteKey: true));
                  if (await checkConnection())
                    _repository.deleteTaskOnFirebase(widget.task);
                  Navigator.pop(context);
                },
              ),
        IconButton(
          icon: Icon(getIconUsingPrefix(name: icons[_iconIndex])),
          onPressed: () {
            _buildIconPicker(context);
          },
        ),
      ],
    );
  }

  Widget _buildCatagories(BuildContext context) {
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: List.generate(
                _catagoryItems.length,
                (index) {
                  if (index == _catagoryItems.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.5),
                      child: GestureDetector(
                        onTap: () {
                          setState(() =>
                              _catagoryItems[index] = !_catagoryItems[index]);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _catagoryItems[index] == false
                                  ? Color(
                                      int.parse(
                                        colors[widget.task.color],
                                      ),
                                    )
                                  : TodoColors.scaffoldWhite,
                              width: 1.3,
                            ),
                            color: _catagoryItems[index]
                                ? Color(
                                    int.parse(colors[widget.task.color]),
                                  )
                                : TodoColors.scaffoldWhite,
                          ),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(
                            right: 5,
                          ),
                          child: FittedBox(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  catagories[index]["iconData"],
                                  size: 15,
                                  color: _catagoryItems[index] == false
                                      ? Color(
                                          int.parse(
                                            colors[widget.task.color],
                                          ),
                                        )
                                      : TodoColors.scaffoldWhite,
                                ),
                                Text(
                                  ' ${catagories[index]["name"]}',
                                  style: TextStyle(
                                    color: _catagoryItems[index] == false
                                        ? Color(
                                            int.parse(
                                                colors[widget.task.color]),
                                          )
                                        : TodoColors.scaffoldWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(
                          () => _catagoryItems[index] = !_catagoryItems[index]);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _catagoryItems[index] == false
                              ? Color(
                                  int.parse(
                                    colors[widget.task.color],
                                  ),
                                )
                              : Colors.white,
                          width: 1.3,
                        ),
                        color: _catagoryItems[index]
                            ? Color(
                                int.parse(colors[widget.task.color]),
                              )
                            : Colors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(
                        right: 5,
                      ),
                      child: FittedBox(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              catagories[index]["iconData"],
                              size: 15,
                              color: _catagoryItems[index] == false
                                  ? Color(
                                      int.parse(
                                        colors[widget.task.color],
                                      ),
                                    )
                                  : Colors.white,
                            ),
                            Text(
                              ' ${catagories[index]["name"]}',
                              style: TextStyle(
                                color: _catagoryItems[index] == false
                                    ? Color(
                                        int.parse(colors[widget.task.color]),
                                      )
                                    : Colors.white,
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
        ),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width - 80,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(int.parse(colors[widget.task.color])),
                    width: 1.3,
                  ),
                ),
                child: TextField(
                  focusNode: myFocusNode,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'Achieve goal',
                    labelStyle: kNormalSuperSmallStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                  ),
                  controller: _achieveTextController,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_achieveTextController.text != '' &&
                      _achieveTextController != null) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      _achievelists.add(_achieveTextController.text
                          .replaceAll(RegExp(r','), 'String.fromCharCode(44)'));
                      _isDoneAchieve.add(false);
                      _achieveTextController.clear();
                    });
                  }
                },
                child: Material(
                  elevation: 1,
                  color: Color(int.parse(colors[widget.task.color])),
                  borderRadius: BorderRadiusDirectional.circular(10),
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Icon(
                      Ionicons.ios_add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildDeleteCheckDialog(BuildContext context) {
    showDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: TodoColors.scaffoldWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 5),
                Text(
                  'Warning:',
                  style: kTitleStyle.copyWith(color: Colors.yellow[900]),
                ),
                Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontFamily: 'Alata',
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 80) / 2,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(int.parse(colors[widget.task.color])),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: kTitleStyle.copyWith(
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          _taskBloc.add(DeleteTaskEvent(
                              task: widget.task, addDeleteKey: true));
                          if (await checkConnection())
                            _repository.deleteTaskOnFirebase(widget.task);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 80) / 2,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(int.parse(colors[widget.task.color])),
                          ),
                          child: Center(
                            child: Text(
                              'Give up',
                              style: kTitleStyle.copyWith(
                                decorationStyle: TextDecorationStyle.double,
                                color: Colors.white,
                                decoration: TextDecoration.none,
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
        ),
      ),
    );
  }

  Widget _buildAchieveTile(int index) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              color: Color(int.parse(colors[widget.task.color])),
              elevation: 5,
              shadowColor:
                  Color(int.parse(colors[widget.task.color])).withOpacity(0.3),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    StringFormatter.format(
                        _achievelists[_achievelists.length - index - 1]),
                    overflow: TextOverflow.clip,
                    style: kNormalStyle.copyWith(
                      decoration:
                          _isDoneAchieve[_achievelists.length - index - 1] ==
                                  false
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                      color: Colors.white,
                      wordSpacing: 0.02,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Icon(
            AntDesign.pushpin,
            color: Colors.red.shade900,
            size: 20,
          ),
          Align(
            alignment: FractionalOffset.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                autofocus: false,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  _isDoneAchieve[_achievelists.length - index - 1]
                      ? AntDesign.checkcircle
                      : AntDesign.checkcircleo,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isDoneAchieve[_achievelists.length - index - 1] =
                        !_isDoneAchieve[_achievelists.length - index - 1];
                  });
                },
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                autofocus: false,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  AntDesign.delete,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isDoneAchieve.removeAt(_achievelists.length - index - 1);
                    _achievelists.removeAt(_achievelists.length - index - 1);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _buildIconPicker(BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: TodoColors.scaffoldWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 5),
                  Text(
                    'Icon',
                    style: TextStyle(fontFamily: 'Alata', fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Divider(),
                  Wrap(
                    direction: Axis.horizontal,
                    children: List.generate(
                      icons.length,
                      (index) {
                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _iconIndex = index;
                                Navigator.pop(context);
                              });
                            },
                            child: Material(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  getIconUsingPrefix(
                                    name: icons[index],
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                              color:
                                  Color(int.parse(colors[widget.task.color])),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Container _buildAddAchieve() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1.5,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Center(
        child: IconButton(
          iconSize: 60,
          icon: Icon(
            Icons.add,
            color: Colors.grey.shade400,
          ),
          onPressed: () => FocusScope.of(context).requestFocus(myFocusNode),
        ),
      ),
    );
  }
}
