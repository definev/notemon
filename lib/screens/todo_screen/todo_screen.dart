import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/do_del_done_todo/bloc/do_del_done_todo_bloc.dart';
import 'package:gottask/bloc/todo/bloc/todo_bloc.dart';
import 'package:gottask/components/image_viewer.dart';
import 'package:gottask/models/do_del_done_todo.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class TodoScreen extends StatefulWidget {
  final Todo todo;
  TodoScreen({this.todo});
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin, BlocCreator {
  AnimationController animationController;
  Animation animation;
  Animation opacityAnimation;
  TextEditingController _todoEditting = TextEditingController();
  bool isExpandCamera = false;
  bool isExpandRecordAudio = false;

  int indexColor;

  bool _haveRecord;
  bool _isInit = false;
  bool _isInitWidget = false;
  bool _isRecording = false;
  bool _isClickMicrophone = false;
  bool _isDelete = false;
  bool _isEdit = false;
  bool _isChecked = false;

  PlayerState _playerState = PlayerState.READY;

  String _mainAudioPath;
  String _subAudioPath;

  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  List<File> imageFileList = [];
  List<String> images = [];
  List<bool> _catagoryItems = List.generate(9, (index) => false);
  String _content;
  final StreamController<String> _contentStreamController =
      StreamController<String>.broadcast();
  DoDelDoneTodoBloc _doDelDoneTodoBloc;
  TodoBloc _todoBloc;
  Todo _currentTask;

  Future _openGallery() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );
    if (imageFile != null) {
      images.add(imageFile.path);
      imageFileList.add(imageFile);
    }
  }

  Future _openCamera() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (imageFile != null) {
      images.add(imageFile.path);
      imageFileList.add(imageFile);
    }
  }

  Future _exist() async => await File('$_subAudioPath').exists();

  @deprecated
  _initPlayer() {
    audioPlayer = AudioPlayer();
    audioPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });
    audioPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });
    audioPlayer.completionHandler = () => setState(() {
          _position = _duration;
          _playerState = PlayerState.READY;
          audioPlayer.stop();
          _position = const Duration();
        });
  }

  Future _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        Directory appDocDirectory;
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        if (await _exist()) {
          final dir = File(_subAudioPath);
          dir.deleteSync(recursive: true);
        }
        String randomName = Uuid().v4();
        _subAudioPath = appDocDirectory.path + '/audio_' + '$randomName.wav';
        _recorder =
            FlutterAudioRecorder(_subAudioPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;

        var current = await _recorder.current(channel: 0);

        setState(() {
          _current = current;
          _currentStatus = current.status;
        });
        _isInit = true;
      } else {
        Scaffold.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must accept permissions'),
          ),
        );
      }
    } catch (e) {
      print(e);
      _isInit = false;
    }
  }

  Future _start() async {
    _isDelete = false;
    try {
      if (_isInit == false) {
        await _init();
        _isInit = true;
      }
      if (audioPlayer.state != AudioPlayerState.STOPPED) {
        await audioPlayer.stop();
      }
      if (_isClickMicrophone == false) {
        _isClickMicrophone = true;
      }
      _recorder.recording;
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
        _isRecording = true;
        _playerState = PlayerState.READY;
      });

      const tick = const Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        try {
          setState(() {
            _current = current;
            _currentStatus = _current.status;
          });
        } catch (e) {}
      });
    } catch (e) {
      print(e);
    }
  }

  @deprecated
  _stop() async {
    var result = await _recorder.stop();
    _initPlayer();
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      _subAudioPath = _current.path;
      _haveRecord = true;
      _isRecording = false;
      _isInit = false;
      _playerState = PlayerState.READY;
      _position = const Duration();
    });
  }

  void _onPlayAudio(String path) async {
    if (_playerState == PlayerState.PAUSE) {
      await audioPlayer.resume();
    } else if (_playerState == PlayerState.READY) {
      await audioPlayer.play(path, isLocal: true);
    }
    setState(() {
      _playerState = PlayerState.PLAY;
    });
  }

  Future _onPauseAudio() async {
    await audioPlayer.pause();
    setState(() {
      _playerState = PlayerState.PAUSE;
    });
  }

  @deprecated
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    opacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(animationController)
          ..addListener(() {
            setState(() {});
          });
    String imagesDecode =
        widget.todo.images.substring(1, widget.todo.images.length - 1);
    images = imagesDecode.split(', ');
    if (images[0] == '') {
      images.removeAt(0);
    }
    images.forEach((path) {
      imageFileList.add(File(path));
    });
    _mainAudioPath = widget.todo.audioPath;
    if (_mainAudioPath != '') {
      _haveRecord = true;
      _initPlayer();
    } else {
      _haveRecord = false;
    }
    _content = widget.todo.content;
    indexColor = widget.todo.color;
    var _rawCatagoryItems = widget.todo.catagories
        .substring(1, widget.todo.catagories.length - 1)
        .split(', ');
    for (int i = 0; i < _rawCatagoryItems.length; i++) {
      if (_rawCatagoryItems[i] == 'false') {
        _catagoryItems[i] = false;
      } else {
        _catagoryItems[i] = true;
      }
    }
    _init();
  }

  @override
  void dispose() async {
    super.dispose();
    if (_playerState != PlayerState.READY) {
      await audioPlayer.stop();
    }
    if (_currentStatus == RecordingStatus.Recording) {
      await _recorder.stop();
    }
    if (_isEdit == false && _isClickMicrophone == true) {
      var dir = File(_subAudioPath);
      dir.deleteSync(recursive: true);
    }
    await _contentStreamController.close();
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5),
      child: Text(
        title,
        style: kNormalStyle.copyWith(color: Colors.grey),
      ),
    );
  }

  @deprecated
  @override
  Widget build(BuildContext context) {
    if (_isInitWidget == false) {
      _todoBloc = findBloc<TodoBloc>();
      _doDelDoneTodoBloc = findBloc<DoDelDoneTodoBloc>();
      _isInitWidget = true;
      _currentTask = widget.todo;
      _isChecked = _currentTask.isDone;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: Color(int.parse(colors[indexColor])),
      ),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: _buildAddTaskButton(context),
        appBar: AppBar(
          backgroundColor: Color(int.parse(colors[indexColor])),
          centerTitle: true,
          title: StreamBuilder(
            initialData: _content,
            stream: _contentStreamController.stream,
            builder: (context, snapshot) => Text(
              snapshot.data,
              style: TextStyle(
                fontFamily: 'Alata',
                decoration: _isChecked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (_isRecording == false) {
                Navigator.pop(context);
              } else {
                showWarning(context);
              }
            },
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() => _isChecked = !_isChecked);
                _currentTask = _currentTask.copyWith(isDone: _isChecked);
                _todoBloc.add(EditTodoEvent(todo: _currentTask));
              },
              child: _isChecked
                  ? FittedBox(
                      child: Container(
                        height: 13,
                        width: 13,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            size: 13,
                            color: Color(int.parse(colors[_currentTask.color])),
                          ),
                        ),
                      ),
                    )
                  : FittedBox(
                      child: Container(
                        height: 13,
                        width: 13,
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
            ),
            IconButton(
              color: Colors.white,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              onPressed: () async {
                _todoBloc.add(DeleteTodoEvent(todo: _currentTask));
                await saveDeleteTask();
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
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTaskNameTextField(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      'Color',
                      style: kNormalStyle.copyWith(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 5),
                  _buildColorPicker(),
                  _buildTitle('Catagory'),
                  SizedBox(height: 5),
                  _buildCatagoriesPicker(),
                  _buildTitle('File'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (isExpandCamera == false) {
                                animationController.forward();
                                setState(() => isExpandCamera = true);
                              } else {
                                animationController.reverse();
                                setState(() => isExpandCamera = false);
                              }
                            },
                            child: _cameraButton(),
                          ),
                          isExpandCamera == true
                              ? GestureDetector(
                                  onTap: () async {
                                    animationController.reverse();
                                    await _openCamera();
                                    setState(() {
                                      isExpandCamera = false;
                                    });
                                  },
                                  child: AnimatedOpacity(
                                    duration: animationController.duration,
                                    opacity: animation.value,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(
                                              int.parse(colors[indexColor])),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Icon(
                                        SimpleLineIcons.camera,
                                        color: Color(
                                            int.parse(colors[indexColor])),
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(height: 0, width: 0),
                          isExpandCamera == true
                              ? GestureDetector(
                                  onTap: () async {
                                    animationController.reverse();
                                    await _openGallery();
                                    setState(() => isExpandCamera = false);
                                  },
                                  child: AnimatedOpacity(
                                    duration: animationController.duration,
                                    opacity: animation.value,
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(
                                              int.parse(colors[indexColor])),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Icon(
                                        SimpleLineIcons.picture,
                                        color: Color(
                                            int.parse(colors[indexColor])),
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(height: 0, width: 0),
                          imageFileList.isEmpty
                              ? isExpandCamera == true
                                  ? Container()
                                  : AnimatedOpacity(
                                      opacity: opacityAnimation.value,
                                      duration: animationController.duration,
                                      child: Text(
                                        'Empty',
                                        style: kTitleStyle.copyWith(
                                            color: Colors.grey),
                                      ),
                                    )
                              : isExpandCamera == true
                                  ? Container()
                                  : LimitedBox(
                                      maxHeight: 100,
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              140,
                                      child: StreamBuilder<List<File>>(
                                        initialData: imageFileList,
                                        builder: (context, snapshot) =>
                                            _buildListImages(snapshot),
                                      ),
                                    ),
                        ],
                      ),
                      _buildMicrophone(context),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @deprecated
  Widget _buildMicrophone(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (_isRecording == false)
              _start();
            else
              _stop();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color(int.parse(colors[indexColor])),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: Icon(
                _isRecording == false ? SimpleLineIcons.microphone : Icons.stop,
                size: 50,
                color: Color(int.parse(colors[indexColor])),
              ),
            ),
          ),
        ),
        _haveRecord
            ? LimitedBox(
                maxHeight: 100,
                maxWidth: MediaQuery.of(context).size.width - 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Color(int.parse(colors[indexColor])),
                        inactiveTrackColor: Colors.grey,
                        trackHeight: 3,
                        thumbColor: Color(int.parse(colors[indexColor])),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 4,
                        ),
                        overlayColor: Color(int.parse(colors[indexColor]))
                            .withOpacity(0.3),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 4,
                        ),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 150,
                        child: Slider(
                          value: _position.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            print(_position.inMilliseconds * value);
                          },
                          onChangeStart: (value) {},
                          onChangeEnd: (value) {},
                          min: 0,
                          max: _duration.inMilliseconds.toDouble(),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (_isRecording == false) {
                              if (_playerState == PlayerState.PLAY) {
                                _onPauseAudio();
                              } else {
                                String path;
                                if (_isClickMicrophone == false) {
                                  path = _mainAudioPath;
                                } else {
                                  path = _subAudioPath;
                                }
                                _onPlayAudio(path);
                              }
                            }
                          },
                          child: Icon(
                            _playerState == PlayerState.PLAY
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 30,
                            color: Color(int.parse(colors[indexColor])),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (_isClickMicrophone == false) {
                              setState(() {
                                _duration = const Duration();
                                _position = const Duration();
                                _haveRecord = false;
                                _isDelete = true;
                              });
                            } else if (_isRecording == false) {
                              if (_playerState == PlayerState.PLAY ||
                                  _playerState == PlayerState.PAUSE) {
                                audioPlayer.stop();
                                final dir = Directory('$_subAudioPath');
                                dir.deleteSync(recursive: true);
                              }
                              _isDelete = true;

                              setState(() {
                                _duration = const Duration();
                                _position = const Duration();
                                _haveRecord = false;
                              });

                              _init();
                            }
                          },
                          child: Icon(
                            Icons.delete_outline,
                            size: 30,
                            color: Color(int.parse(colors[indexColor])),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Text(
                'Empty',
                style: kTitleStyle.copyWith(color: Colors.grey),
              ),
      ],
    );
  }

  ListView _buildListImages(AsyncSnapshot<List<File>> snapshot) =>
      ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: 100,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewer(
                            color: Color(int.parse(colors[indexColor])),
                            imageLinkList: snapshot.data,
                            imageLinkIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.file(
                      snapshot.data[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Align(
                    alignment: FractionalOffset.topRight,
                    child: GestureDetector(
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white38,
                        child: Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                      onTap: () {
                        images.removeAt(index);
                        setState(() {
                          snapshot.data.removeAt(index);
                        });
                      },
                    ),
                  ),
                ),
                Container(),
              ],
            ),
          ),
        ),
      );

  Widget _cameraButton() => AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: const EdgeInsets.all(10),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(int.parse(colors[indexColor])),
            width: 1,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: FractionalOffset.center,
              child: AnimatedOpacity(
                duration: animationController.duration,
                opacity: animation.value,
                child: Icon(
                  Ionicons.ios_arrow_back,
                  color: Color(int.parse(colors[indexColor])),
                  size: 50,
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.center,
              child: AnimatedOpacity(
                duration: animationController.duration,
                opacity: opacityAnimation.value,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Icon(
                    SimpleLineIcons.camera,
                    color: Color(int.parse(colors[indexColor])),
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Container _buildTaskNameTextField() => Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(int.parse(colors[indexColor])),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _todoEditting,
          onChanged: (value) {
            _content = value;
            _contentStreamController.sink.add(_content);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: 'Rename to-do',
            labelStyle: kNormalStyle.copyWith(color: Colors.grey),
            focusColor: TodoColors.lightOrange,
            border: InputBorder.none,
          ),
        ),
      );

  Widget _buildAddTaskButton(BuildContext context) => GestureDetector(
        onTap: () {
          if (_isRecording == false) {
            _isEdit = true;
            String _audioPath;
            if (_isDelete == true) {
              _audioPath = '';
            } else {
              _audioPath = _isClickMicrophone ? _subAudioPath : _mainAudioPath;
            }
            _currentTask = _currentTask.copyWith(
              content: _todoEditting.text != ''
                  ? _todoEditting.text
                  : _currentTask.content,
              images: images.toString(),
              color: indexColor,
              audioPath: _audioPath,
              catagories: _catagoryItems.toString(),
            );
            _todoBloc.add(
              EditTodoEvent(
                todo: _currentTask.copyWith(
                  content: _todoEditting.text != ''
                      ? _todoEditting.text
                      : _currentTask.content,
                  images: images.toString(),
                  color: indexColor,
                  audioPath: _audioPath,
                  catagories: _catagoryItems.toString(),
                ),
              ),
            );
            Navigator.pop(context);
          } else {
            showWarning(context);
          }
        },
        child: AnimatedContainer(
          color: Color(int.parse(colors[indexColor])),
          duration: Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  AntDesign.edit,
                  color: Colors.white,
                ),
                Text(
                  ' Edit to-do',
                  style: kNormalStyle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );

  Future showWarning(BuildContext context) => showDialog(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              height: 200,
              width: 400,
              decoration: BoxDecoration(
                color: TodoColors.scaffoldWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Warning:',
                    style: TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 30,
                      decorationStyle: TextDecorationStyle.double,
                      color: Colors.yellow[900],
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    'Do not go out if recording not done.',
                    style: kTitleStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(int.parse(colors[indexColor])),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Alata',
                              fontSize: 30,
                              decorationStyle: TextDecorationStyle.double,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildCatagoriesPicker() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
      ),
      child: Wrap(
        children: List.generate(
          catagories.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _catagoryItems[index] = !_catagoryItems[index];
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _catagoryItems[index] == false
                      ? Color(
                          int.parse(
                            colors[indexColor],
                          ),
                        )
                      : Colors.white,
                ),
                color: _catagoryItems[index]
                    ? Color(
                        int.parse(
                          colors[indexColor],
                        ),
                      )
                    : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(
                bottom: 5,
                right: 5,
              ),
              child: FittedBox(
                child: Row(
                  children: <Widget>[
                    Icon(
                      catagoryIcons[index],
                      size: 15,
                      color: _catagoryItems[index] == false
                          ? Color(
                              int.parse(
                                colors[indexColor],
                              ),
                            )
                          : Colors.white,
                    ),
                    Text(
                      ' ${catagories[index]}',
                      style: TextStyle(
                        color: _catagoryItems[index] == false
                            ? Color(
                                int.parse(
                                  colors[indexColor],
                                ),
                              )
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          direction: Axis.horizontal,
          children: List.generate(
            colors.length,
            (index) {
              if (indexColor == index) {
                return Container(
                  margin: const EdgeInsets.all(3),
                  height: (MediaQuery.of(context).size.width - 59) / 6,
                  width: (MediaQuery.of(context).size.width - 59) / 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(
                      int.parse(colors[index]),
                    ),
                  ),
                  child: Icon(Icons.check, color: Colors.white),
                );
              }
              return GestureDetector(
                onTap: () {
                  setState(() => indexColor = index);
                },
                child: Container(
                  margin: const EdgeInsets.all(3),
                  height: (MediaQuery.of(context).size.width - 59) / 6,
                  width: (MediaQuery.of(context).size.width - 59) / 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(
                      int.parse(colors[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}
