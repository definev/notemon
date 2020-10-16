import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_incall/flutter_incall.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/countdown_clock.dart';
import 'package:gottask/components/parrallel_background.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/task_screen/task_screen_subscreen/edit_task_screen.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:vibration/vibration.dart';
import 'package:get/get.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}

class TaskScreen extends StatefulWidget {
  final Task task;
  final bool removeAds;

  TaskScreen({this.task, @required this.removeAds});
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with BlocCreator {
  Task _currentTask;

  List<String> _achievelists;
  Duration _timer;
  int _percent;
  int _maxTimer;

  bool _isInit = false;

  List<bool> _isDoneAchieve = [];
  List<bool> _categoryItems =
      List.generate(catagories.length, (index) => false);

  SlideCountdownClock countdownClock;
  TimerState _timerState = TimerState.PAUSE;

  TaskBloc _taskBloc;
  StarBloc _starBloc;
  FirebaseRepository _repository;
  TextEditingController _achieveTextController = TextEditingController();
  PageController _pageController = PageController();

  FocusNode achieveFocusNode;
  IncallManager _incallManager = IncallManager();
  bool isProcess = true;
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();

  InterstitialAd myInterstitial;

  InterstitialAd _interstitialAds() =>
      InterstitialAd(adUnitId: interstitialId, targetingInfo: targetingInfo);

  StreamSubscription<AudioPlayerState> onStateChanged;

  _onBackPress() async {
    //Back and update data
    List<String> durTimer = _currentTask.timer.split(':');
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
        task: _currentTask.copyWith(
          achieve: _achievelists,
          catagories: _categoryItems,
          completeTimer: _completeTimer.toString(),
          isDoneAchieve: _isDoneAchieve,
          percent: _percent,
        ),
      ),
    );
    _repository.updateTaskToFirebase(
      _currentTask.copyWith(
        achieve: _achievelists,
        catagories: _categoryItems,
        completeTimer: _completeTimer.toString(),
        isDoneAchieve: _isDoneAchieve,
        percent: _percent,
      ),
    );
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty &&
          !(await _repository.getRemoveAdsState())) {
        myInterstitial
          ..load()
          ..show();
      }
    } on SocketException catch (_) {}
    Get.back();
    return true;
  }

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;

    if (!_currentTask.onDoing) {
      FirebaseAdMob.instance.initialize(appId: appId);
      myInterstitial = _interstitialAds();

      achieveFocusNode = FocusNode();
      _categoryItems = _currentTask.catagories;

      _achievelists = _currentTask.achieve;
      List<String> durTimer = _currentTask.timer.split(':');
      List<String> durCompleteTimer = _currentTask.completeTimer.split(':');
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
          int.parse(durTimerSecond[0]);
      _percent = _currentTask.percent;
      if (_timer == Duration(hours: 0, minutes: 0, seconds: 0)) {
        _timerState = TimerState.DONE;
      }

      if (_timerState != TimerState.DONE) {
        if (Platform.isAndroid) {
          _incallManager.enableProximitySensor(true);
          _incallManager.turnScreenOff();
          _incallManager.onProximity.stream.listen(
            (proximity) async {
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
                      _currentTask.copyWith(
                        onDoing: true,
                        achieve: _achievelists,
                        catagories: _categoryItems,
                        completeTimer: _completeTimer.toString(),
                        isDoneAchieve: _isDoneAchieve,
                        percent: _percent,
                      ),
                    );
                  }
                  if (mounted)
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
                        task: _currentTask.copyWith(
                          achieve: _achievelists,
                          catagories: _categoryItems,
                          completeTimer: _completeTimer.toString(),
                          isDoneAchieve: _isDoneAchieve,
                          percent: _percent,
                        ),
                      ),
                    );
                    _repository.updateTaskToFirebase(
                      _currentTask.copyWith(
                        onDoing: false,
                        achieve: _achievelists,
                        catagories: _categoryItems,
                        completeTimer: _completeTimer.toString(),
                        isDoneAchieve: _isDoneAchieve,
                        percent: _percent,
                      ),
                    );
                  });
                  if (audioPlayer.state == AudioPlayerState.PLAYING) {
                    await audioPlayer.stop();
                    onStateChanged.cancel();
                  }
                }
              }
            },
          );
        }
      }

      countdownClock = SlideCountdownClock(
        duration: Duration(
          hours: _timer.inHours,
          minutes: _timer.inMinutes.remainder(60),
          seconds: _timer.inSeconds.remainder(60),
        ),
        onChanged: (duration) {
          _timer = duration;
          setState(() => _percent++);
        },
        onDone: () async {
          audioPlayer = await audioCache.loop(audioFile['Caught_Pokemon']);

          onStateChanged = audioPlayer.onPlayerStateChanged.listen((_) async {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate(duration: 100, amplitude: 200);
            }
          });

          var maxTime = Duration(
            hours: int.parse(durTimer[0]),
            minutes: int.parse(durTimer[1]),
            seconds: int.parse(durTimerSecond[0]),
          );

          setState(() => _timerState = TimerState.DONE);

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
      _isDoneAchieve = _currentTask.isDoneAchieve;
    }
  }

  @override
  void dispose() {
    if (achieveFocusNode != null) achieveFocusNode.dispose();
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

    return _currentTask.onDoing == false
        ? _bodyOnDoingFalse(context)
        : _bodyOnDoingTrue();
  }

  Theme _bodyOnDoingFalse(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: Color(int.parse(colors[_currentTask.color])),
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
                  _buildNote(context),
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
                        "${"Doing in another device".tr},\n",
                        style: kBigTitleStyle.copyWith(
                            fontFamily: 'Source_Sans_Pro',
                            color: Colors.white,
                            fontSize: 35),
                      ),
                      Text(
                        "${"Don't distract!".tr} 😊",
                        style: kBigTitleStyle.copyWith(
                            fontFamily: 'Source_Sans_Pro',
                            color: Colors.white,
                            fontSize: 35),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Get.back(),
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

  Widget _buildNote(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 140,
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          Text(
            '${_currentTask.taskName}',
            style: TextStyle(
              fontFamily: 'Alata',
              fontSize: MediaQuery.of(context).size.width / 25,
            ),
          ),
          countdownClock,
          Container(
            height: MediaQuery.of(context).size.height / 4,
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(int.parse(colors[_currentTask.color]))
                      .withOpacity(0.1),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: 5,
                        color: Color(int.parse(colors[_currentTask.color]))
                            .withOpacity(0.5),
                      ),
                      AnimatedContainer(
                        height: 5,
                        width: _percent /
                            _maxTimer *
                            (MediaQuery.of(context).size.width - 20),
                        duration: Duration(milliseconds: 200),
                        color: Color(int.parse(colors[_currentTask.color])),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "“Facedown your phone to start timing.”".tr,
                        style: kMediumStyle,
                      ),
                      Text(
                        "— Notemon",
                        style: GoogleFonts.getFont(
                          'Dancing Script',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_achievelists.length != 0)
            Expanded(
              child: PageView.builder(
                physics: BouncingScrollPhysics(),
                controller: _pageController,
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
        'Doing task'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(int.parse(colors[_currentTask.color])),
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
                onPressed: () async => await _buildDeleteCheckDialog(context),
              )
            : IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {
                  _taskBloc.add(
                      DeleteTaskEvent(task: _currentTask, addDeleteKey: true));
                  if (await checkConnection())
                    _repository.deleteTaskOnFirebase(_currentTask);
                  Get.back();
                },
              ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            Task _editTask = await showModalBottomSheet(
              context: context,
              builder: (context) => EditTaskScreen(task: _currentTask),
            );

            if (_editTask != null) {
              _taskBloc.add(EditTaskEvent(task: _editTask));

              setState(() => _currentTask = _editTask);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCatagories(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(
            bottom: 10,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 16,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(int.parse(colors[_currentTask.color])),
                            width: 1.2,
                          ),
                        ),
                        child: TextField(
                          focusNode: achieveFocusNode,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            labelText: 'Achieve goal'.tr,
                            labelStyle:
                                kNormalStyle.copyWith(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          controller: _achieveTextController,
                          style: kNormalStyle.copyWith(
                            fontFamily: "Source_Sans_Pro",
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_achieveTextController.text != '' &&
                            _achieveTextController != null) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            _achievelists.add(_achieveTextController.text
                                .replaceAll(
                                    RegExp(r','), 'String.fromCharCode(44)'));
                            _isDoneAchieve.add(false);
                            _achieveTextController.clear();
                            _pageController
                                .jumpToPage(_pageController.page.toInt() + 1);
                            _pageController.animateToPage(
                              0,
                              duration: Duration(
                                  milliseconds:
                                      (_pageController.page.toInt()) * 200),
                              curve: Curves.fastOutSlowIn,
                            );
                          });
                        }
                      },
                      child: Material(
                        elevation: 1,
                        color: Color(int.parse(colors[_currentTask.color])),
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
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 5),
                Text(
                  'Warning:'.tr,
                  style: kTitleStyle.copyWith(color: Colors.yellow[900]),
                ),
                Text(
                  'Are you sure?'.tr,
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
                          Get.back();
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 80) / 2,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(int.parse(colors[_currentTask.color])),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel'.tr,
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
                              task: _currentTask, addDeleteKey: true));
                          if (await checkConnection())
                            _repository.deleteTaskOnFirebase(_currentTask);
                          Get.back();
                          Get.back();
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 80) / 2,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(int.parse(colors[_currentTask.color])),
                          ),
                          child: Center(
                            child: Text(
                              'Give up'.tr,
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
      width: MediaQuery.of(context).size.width / 1.3,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
                topLeft: Radius.circular(15),
              ),
              color: Color(int.parse(colors[_currentTask.color])),
              elevation: 3,
              shadowColor:
                  Color(int.parse(colors[_currentTask.color])).withOpacity(0.3),
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
          // Icon(
          //   AntDesign.pushpin,
          //   color: Colors.red.shade900,
          //   size: 20,
          // ),
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

  Widget _buildAddAchieve() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(achieveFocusNode);
      },
      child: Container(
        // width: MediaQuery.of(context).size.width / 1.5,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.grey.shade400,
            size: 60,
          ),
        ),
      ),
    );
  }
}
