import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/image_viewer.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AddTodoScreen extends StatefulWidget {
  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen>
    with SingleTickerProviderStateMixin, BlocCreator {
  AnimationController animationController;
  Animation animation;
  Animation opacityAnimation;
  int indexColor = 0;

  final TextEditingController _todoEditting = TextEditingController();
  bool isExpandCamera = false;
  bool _isRecording = false;
  bool isCreate = false;
  bool _haveRecord = false;
  bool _isInit = false;
  bool _isInitWidget = false;

  PlayerState _playerState = PlayerState.READY;
  List<Uint8List> imageFileList = [];
  List<String> images = [];
  List<bool> _catagoryItems = List.generate(9, (index) => false);

  String _audioPath = '';
  String _audioCode = '';

  Directory appDocDirectory;
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  TodoBloc _todoBloc;
  FirebaseRepository _repository;

  Future _openGallery() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );
    if (imageFile != null) {
      images.add(base64Encode(imageFile.readAsBytesSync()));
      imageFileList.add(imageFile.readAsBytesSync());
    }
  }

  Future _openCamera() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (imageFile != null) {
      images.add(base64Encode(imageFile.readAsBytesSync()));
      imageFileList.add(imageFile.readAsBytesSync());
    }
  }

  Future<bool> _exist() async => await File('$_audioPath').exists();

  Future<void> _init() async {
    try {
      if (Platform.isIOS) {
        PermissionStatus permission = await PermissionHandler()
            .checkPermissionStatus(PermissionGroup.camera);
        if (permission.value == 0) {}
      }
      if (Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }

      if (await FlutterAudioRecorder.hasPermissions) {
        if (await _exist()) {
          final dir = File(appDocDirectory.path + _audioPath);
          dir.deleteSync(recursive: true);
        }
        String randomName = Uuid().v4();
        _audioPath = '/audio_$randomName.wav';
        String _path = "${appDocDirectory.path}$_audioPath";
        _recorder = FlutterAudioRecorder(_path, audioFormat: AudioFormat.WAV);

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
            content: const Text('You must accept permissions'),
          ),
        );
      }
    } catch (e) {
      print(e);
      _isInit = false;
    }
  }

  @deprecated
  void initPlayer() {
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);

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

  Future _start() async {
    try {
      if (audioPlayer.state != AudioPlayerState.STOPPED) {
        await audioPlayer.stop();
      }
      if (await _exist() == true) {
        final dir = File('${appDocDirectory.path}$_audioPath');
        dir.deleteSync(recursive: true);
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
        } catch (e) {
          var res = _recorder.recording;
          if (res.status != RecordingStatus.Stopped) {
            await _recorder.stop();
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @deprecated
  Future _stop() async {
    _isInit = true;
    var result = await _recorder.stop();
    File _audioFile = File(result.path);
    _audioCode = base64Encode(_audioFile.readAsBytesSync());
    initPlayer();
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      _audioPath = _current.path.substring(
          _current.path.length - _audioPath.length, _current.path.length);
      _haveRecord = true;
      _isRecording = false;
      _playerState = PlayerState.READY;
      _position = const Duration();
    });
  }

  Future onPlayAudio() async {
    if (_isInit == false) {
      await _init();
    }
    if (_playerState == PlayerState.PAUSE) {
      await audioPlayer.resume();
    } else if (_playerState == PlayerState.READY) {
      String path = "${appDocDirectory.path}$_audioPath";
      if (File(path).existsSync()) await audioPlayer.play(path, isLocal: true);
    }
    setState(() {
      _playerState = PlayerState.PLAY;
    });
  }

  Future<void> onPauseAudio() async {
    await audioPlayer.pause();
    setState(() {
      _playerState = PlayerState.PAUSE;
    });
  }

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

    _init();
  }

  _deleteFile() {
    if (_haveRecord) {
      final dir = Directory("${appDocDirectory.path}$_audioPath");
      dir.deleteSync(recursive: true);
      _audioCode = '';
    }
  }

  @override
  dispose() async {
    super.dispose();
    if (_playerState != PlayerState.READY) {
      await audioPlayer.stop();
    }
    if (_currentStatus == RecordingStatus.Recording) {
      await _recorder.stop();
      _haveRecord = true;
    }
    if (isCreate == false) {
      _deleteFile();
    }
    imageFileList.forEach((imageFile) => print(imageFile));
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
      _repository = findBloc<FirebaseRepository>();
      _isInitWidget = true;
    }

    return Theme(
      data: Theme.of(context)
          .copyWith(accentColor: Color(int.parse(colors[indexColor]))),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: _buildAddTaskButton(context),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Text(
                          'Color',
                          style: kNormalStyle.copyWith(color: Colors.grey),
                        ),
                      ),
                      _buildColorPicker(),
                      _buildTitle('Catagory'),
                      _buildCatagoriesPicker(),
                    ],
                  ),
                  _buildTitle('File'),
                  _buildCameraPicker(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @deprecated
  Column _buildCameraPicker(BuildContext context) {
    return Column(
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
                  setState(() {
                    isExpandCamera = true;
                  });
                } else {
                  animationController.reverse();
                  setState(() {
                    isExpandCamera = false;
                  });
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
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 10),
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
                        child: Icon(
                          SimpleLineIcons.camera,
                          color: Color(int.parse(colors[indexColor])),
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
                      setState(() {
                        isExpandCamera = false;
                      });
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
                            color: Color(int.parse(colors[indexColor])),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Icon(
                          SimpleLineIcons.picture,
                          color: Color(int.parse(colors[indexColor])),
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
                          style: kTitleStyle.copyWith(color: Colors.grey),
                        ),
                      )
                : isExpandCamera == true
                    ? Container()
                    : LimitedBox(
                        maxHeight: 100,
                        maxWidth: MediaQuery.of(context).size.width - 140,
                        child: StreamBuilder<List<Uint8List>>(
                          initialData: imageFileList,
                          builder: (context, snapshot) =>
                              _buildListImages(snapshot),
                        ),
                      ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (_isRecording == false) {
                  _start();
                } else {
                  _stop();
                }
              },
              child: Container(
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
                child: Icon(
                  _isRecording == false
                      ? SimpleLineIcons.microphone
                      : Icons.stop,
                  size: 50,
                  color: Color(int.parse(colors[indexColor])),
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
                            activeTrackColor:
                                Color(int.parse(colors[indexColor])),
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
                              onChanged: (value) {},
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
                                    onPauseAudio();
                                  } else {
                                    if (_playerState == PlayerState.READY ||
                                        _playerState == PlayerState.PAUSE) {
                                      onPlayAudio();
                                    }
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
                                if (_isRecording == false) {
                                  if (_playerState == PlayerState.PLAY ||
                                      _playerState == PlayerState.PAUSE) {
                                    audioPlayer.stop();
                                    final dir = Directory(
                                        "${appDocDirectory.path}$_audioPath");
                                    dir.deleteSync(recursive: true);
                                  }
                                  _audioPath = '';
                                  _audioCode = '';

                                  setState(() {
                                    _duration = const Duration();
                                    _position = const Duration();
                                  });

                                  _init();
                                  setState(() {
                                    _haveRecord = false;
                                  });
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
        ),
      ],
    );
  }

  Widget _buildCatagoriesPicker() => Padding(
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
                duration: Duration(milliseconds: 100),
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
                  setState(() {
                    indexColor = index;
                  });
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

  ListView _buildListImages(AsyncSnapshot<List<Uint8List>> snapshot) =>
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
                    child: Image.memory(
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
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      onTap: () {
                        images.removeAt(index);
                        setState(() => snapshot.data.removeAt(index));
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

  Container _cameraButton() => Container(
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
                  size: 50,
                  color: Color(int.parse(colors[indexColor])),
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.center,
              child: AnimatedOpacity(
                duration: animationController.duration,
                opacity: opacityAnimation.value,
                child: Icon(
                  SimpleLineIcons.camera,
                  size: 50,
                  color: Color(int.parse(colors[indexColor])),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildTaskNameTextField() => AnimatedContainer(
        duration: Duration(milliseconds: 100),
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
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: 'To-do name',
            labelStyle: kNormalStyle.copyWith(color: Colors.grey),
            focusColor: TodoColors.lightOrange,
            border: InputBorder.none,
          ),
        ),
      );

  Widget _buildAddTaskButton(BuildContext context) => GestureDetector(
        onTap: () async {
          if (_isRecording == false) {
            isCreate = true;
            String id = Uuid().v1();
            Todo _todo = Todo(
              content: _todoEditting.text,
              id: id,
              state: "notDone",
              images: images.toString(),
              color: indexColor,
              audioPath: _haveRecord ? _audioPath : '',
              audioCode: _haveRecord ? _audioCode : '',
              catagories: _catagoryItems.toString(),
            );
            print(_todo.toMap());
            _todoBloc.add(AddTodoEvent(todo: _todo));

            if (await checkConnection())
              _repository.updateTodoToFirebase(_todo);

            Navigator.pop(context);
          } else {
            await showWarning(context);
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Ionicons.ios_add,
                  color: Colors.white,
                ),
                Text(
                  ' Add to-do',
                  style: kNormalStyle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          color: Color(int.parse(colors[indexColor])),
        ),
      );

  Future showWarning(BuildContext context) => showDialog(
        context: context,
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
                const SizedBox(height: 20),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
      );
}
