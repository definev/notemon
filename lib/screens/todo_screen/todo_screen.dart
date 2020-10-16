import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/image_viewer.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class TodoScreen extends StatefulWidget {
  final Todo todo;
  TodoScreen({this.todo});
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin, BlocCreator, FilterMixin {
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
  String _mainAudioCode;
  String _subAudioPath;
  String _subAudioCode;
  PriorityState _priority;

  Directory appDocDirectory;
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  List<Uint8List> imageFileList = [];
  List<String> images = [];
  List<bool> _categoryItems = List.generate(9, (index) => false);

  String _content;
  final StreamController<String> _contentStreamController =
      StreamController<String>.broadcast();

  TodoBloc _todoBloc;
  StarBloc _starBloc;
  FirebaseRepository _repository;
  Todo _currentTask;

  Future _openGallery() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    print("FILE SIZE BEFORE: " + imageFile.lengthSync().toString());

    if (imageFile != null) {
      images.add(base64Encode(imageFile.readAsBytesSync()));
      imageFileList.add(imageFile.readAsBytesSync());
    }
  }

  Future _openCamera() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    print("FILE SIZE BEFORE: " + imageFile.lengthSync().toString());

    if (imageFile != null) {
      images.add(base64Encode(imageFile.readAsBytesSync()));
      imageFileList.add(imageFile.readAsBytesSync());
    }
  }

  @deprecated
  _initPlayer() async {
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
      bool _hasConnect = await FlutterAudioRecorder.hasPermissions;
      if (_hasConnect) {
        String randomName = Uuid().v4();
        _subAudioPath = '/audio_$randomName.wav';
        String path = appDocDirectory.path + _subAudioPath;
        if (File(path).existsSync()) {
          final dir = File(path);
          dir.deleteSync(recursive: true);
        }

        _recorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;

        var current = await _recorder.current(channel: 0);

        setState(() {
          _current = current;
          _currentStatus = current.status;
        });
        _isInit = true;
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('You must accept permissions'.tr)),
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
      if (audioPlayer.state != AudioPlayerState.STOPPED)
        await audioPlayer.stop();

      if (_isInit == false) await _init();

      if (_isClickMicrophone == false) _isClickMicrophone = true;

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
    File _audioFile = File(result.path);
    _initPlayer();
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      _subAudioPath = _current.path.substring(
          _current.path.length - _subAudioPath.length, _current.path.length);
      _subAudioCode = base64Encode(_audioFile.readAsBytesSync());
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

  Future<void> _setDirectory() async {
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
  }

  Future<void> _setMainAudioFile() async {
    await _setDirectory();
    if (!File(_mainAudioPath).existsSync()) {
      File _audioFile = File(appDocDirectory.path + _mainAudioPath);
      _audioFile.writeAsBytesSync(base64Decode(_mainAudioCode));
    }
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
    if (images[0] == '') images.removeAt(0);

    images.forEach((path) => imageFileList.add(base64Decode(path)));
    _mainAudioPath = widget.todo.audioPath;
    _mainAudioCode = widget.todo.audioCode;
    if (_mainAudioPath != '') {
      _haveRecord = true;
      _setMainAudioFile();
      _initPlayer();
    } else {
      _haveRecord = false;
      _setDirectory();
    }
    _content = widget.todo.content;
    indexColor = widget.todo.color;
    _categoryItems = widget.todo.catagories;
    _priority = widget.todo.priority;
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
    if (_isEdit == false &&
        _isClickMicrophone == true &&
        _subAudioPath != null &&
        _subAudioPath != '') {
      var dir = File(appDocDirectory.path + _subAudioPath);
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
    await _contentStreamController.close();
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, top: 2, bottom: 5),
      child: Text(
        title.tr,
        style: kNormalStyle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  @deprecated
  @override
  Widget build(BuildContext context) {
    if (_isInitWidget == false) {
      _todoBloc = findBloc<TodoBloc>();
      _starBloc = findBloc<StarBloc>();
      _repository = findBloc<FirebaseRepository>();
      _isInitWidget = true;
      _currentTask = widget.todo;
      _isChecked = _currentTask.state == "done" ? true : false;
    }
    return Theme(
      data: Theme.of(context)
          .copyWith(accentColor: Color(int.parse(colors[indexColor]))),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: _buildEditTodoButton(context),
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
                Get.back();
              } else {
                showWarning(context);
              }
            },
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                setState(() => _isChecked = !_isChecked);
                _currentTask = _currentTask.copyWith(
                    state: _isChecked ? "done" : "notDone");
                _todoBloc.add(EditTodoEvent(todo: _currentTask));
                if (await checkConnection())
                  _repository.updateTodoToFirebase(_currentTask);
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
                _currentTask.state == "done"
                    ? Icons.check
                    : Icons.delete_outline,
                color: Colors.white,
              ),
              onPressed: () async {
                _todoBloc.add(
                    DeleteTodoEvent(todo: _currentTask, addDeleteKey: true));

                if (_currentTask.state == "done")
                  _starBloc.add(AddStarEvent(point: 1));
                _repository.deleteTodoOnFirebase(_currentTask);
                Get.back();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTaskNameTextField(),
                  _buildTitle('Color'),
                  _buildColorPicker(),
                  _buildTitle('Priority'),
                  _buildPriorityPicker(),
                  _buildTitle('Category'),
                  _buildCatagoriesPicker(context),
                  _buildTitle('File'),
                  _buildFilePicker(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @deprecated
  Column _buildFilePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildCameraPicker(context),
        _buildMicrophonePicker(context),
      ],
    );
  }

  Row _buildCameraPicker(BuildContext context) {
    return Row(
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
        const SizedBox(width: 10),
        isExpandCamera == true
            ? _functionCameraButton(
                onTap: () async {
                  animationController.reverse();
                  await _openCamera();
                  setState(() {
                    isExpandCamera = false;
                  });
                },
                iconData: SimpleLineIcons.camera,
              )
            : Container(),
        isExpandCamera == true
            ? _functionCameraButton(
                onTap: () async {
                  animationController.reverse();
                  await _openGallery();
                  setState(() => isExpandCamera = false);
                },
                iconData: SimpleLineIcons.picture,
              )
            : Container(),
        imageFileList.isEmpty
            ? isExpandCamera == true
                ? Container()
                : Expanded(
                    child: AnimatedOpacity(
                      opacity: opacityAnimation.value,
                      duration: animationController.duration,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: opacityAnimation.value,
                          duration: animationController.duration,
                          child: Text(
                            'No files'.tr,
                            style: kTitleStyle.copyWith(color: Colors.grey),
                          ),
                        ),
                      ),
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
    );
  }

  Widget _functionCameraButton({
    VoidCallback onTap,
    IconData iconData,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: animationController.duration,
        opacity: animation.value,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 100,
          height: 100,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(int.parse(colors[indexColor])),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
            iconData,
            color: Color(int.parse(colors[indexColor])),
            size: 50,
          ),
        ),
      ),
    );
  }

  @deprecated
  Widget _buildMicrophonePicker(BuildContext context) {
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
            margin: const EdgeInsets.only(top: 10),
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
        const SizedBox(width: 10),
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
                        inactiveTrackColor: Colors.grey[350],
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
                                  path = appDocDirectory.path + _mainAudioPath;
                                } else {
                                  path = appDocDirectory.path + _subAudioPath;
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
                                final dir =
                                    File(appDocDirectory.path + _subAudioPath);
                                dir.deleteSync(recursive: true);
                                _subAudioCode = '';
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
            : Expanded(
                child: Center(
                  child: Text(
                    'No files'.tr,
                    style: kTitleStyle.copyWith(color: Colors.grey),
                  ),
                ),
              ),
      ],
    );
  }

  ListView _buildListImages(AsyncSnapshot<List<Uint8List>> snapshot) =>
      ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          if (index == snapshot.data.length - 1) {
            return SizedBox(
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
                            color: Colors.white54,
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
            );
          }
          return Padding(
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
                            color: Colors.white54,
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
          );
        },
      );

  Widget _cameraButton() => AnimatedContainer(
        duration: Duration(milliseconds: 200),
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
            labelText: 'Rename to-do'.tr,
            labelStyle: kNormalStyle.copyWith(color: Colors.grey),
            focusColor: TodoColors.lightOrange,
            border: InputBorder.none,
          ),
        ),
      );

  Widget _buildEditTodoButton(BuildContext context) => GestureDetector(
        onTap: () async {
          if (_isRecording == false) {
            _isEdit = true;
            String _audioPath, _audioCode;
            if (_isDelete == true) {
              _audioPath = '';
              _audioCode = '';
            } else {
              _audioPath = _isClickMicrophone ? _subAudioPath : _mainAudioPath;
              _audioCode = _isClickMicrophone ? _subAudioCode : _subAudioCode;
            }
            _currentTask = _currentTask.copyWith(
              content: _todoEditting.text != ''
                  ? _todoEditting.text
                  : _currentTask.content,
              images: images.toString(),
              color: indexColor,
              audioPath: _audioPath,
              audioCode: _audioCode,
              catagories: _categoryItems,
              priority: _priority,
            );
            _todoBloc.add(EditTodoEvent(todo: _currentTask));
            if (await checkConnection())
              _repository.updateTodoToFirebase(_currentTask);

            Get.back();
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
                  ' ${"Edit to-do".tr}',
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
                    'Warning:'.tr,
                    style: TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 30,
                      decorationStyle: TextDecorationStyle.double,
                      color: Colors.yellow[900],
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    'Do not go out if recording not done.'.tr,
                    style: kTitleStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(int.parse(colors[indexColor])),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel'.tr,
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

  Widget _buildPriorityPicker() {
    return Row(
      children: [
        _priorityTile(PriorityState.High.index),
        SizedBox(width: 10),
        _priorityTile(PriorityState.Medium.index),
        SizedBox(width: 10),
        _priorityTile(PriorityState.Low.index),
      ],
    );
  }

  Widget _priorityTile(int value) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_priority != PriorityState.values[value]) {
            _priority = PriorityState.values[value];
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 45,
        width: (MediaQuery.of(context).size.width - 50) / 3,
        decoration: BoxDecoration(
          color: _priority != PriorityState.values[value]
              ? TodoColors.scaffoldWhite
              : setPriorityColor(priorityList[value]),
          border: Border.all(
            color: _priority == PriorityState.values[value]
                ? TodoColors.scaffoldWhite
                : setPriorityColor(priorityList[value]),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            priorityList[value].tr,
            style: kNormalStyle.copyWith(
              color: _priority == PriorityState.values[value]
                  ? TodoColors.scaffoldWhite
                  : setPriorityColor(priorityList[value]),
            ),
          ),
        ),
      ),
    );
  }

  setPriorityColor(String value) {
    if (value == "Low") {
      return TodoColors.lightGreen;
    } else if (value == "Medium") {
      return TodoColors.chocolate;
    } else if (value == "High") {
      return TodoColors.massiveRed;
    } else
      return TodoColors.blueAqua;
  }

  Widget _buildCatagoriesPicker(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: List.generate(
        catagories.length,
        (index) {
          String category = catagories[index]["name"];
          return GestureDetector(
            onTap: () {
              setState(() {
                _categoryItems[index] = !_categoryItems[index];
              });
            },
            child: AnimatedContainer(
              height: 45,
              width: (MediaQuery.of(context).size.width - 50) / 3,
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _categoryItems[index] == false
                      ? Color(
                          int.parse(
                            colors[indexColor],
                          ),
                        )
                      : TodoColors.scaffoldWhite,
                  width: 1,
                ),
                color: _categoryItems[index]
                    ? Color(
                        int.parse(
                          colors[indexColor],
                        ),
                      )
                    : TodoColors.scaffoldWhite,
              ),
              padding: paddingCategory(),
              margin: marginCategory(index),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    catagories[index]["iconData"],
                    size: iconSize(),
                    color: _categoryItems[index] == false
                        ? Color(
                            int.parse(
                              colors[indexColor],
                            ),
                          )
                        : TodoColors.scaffoldWhite,
                  ),
                  Text(
                    '${category.tr}',
                    style: TextStyle(
                      fontFamily: 'Source_Sans_Pro',
                      fontSize: fontSize(),
                      color: _categoryItems[index] == false
                          ? Color(
                              int.parse(
                                colors[indexColor],
                              ),
                            )
                          : TodoColors.scaffoldWhite,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: (MediaQuery.of(context).size.width - 60) / 3 + 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              colors.length ~/ 2,
              (index) {
                if (indexColor == index) {
                  return _colorTile(
                    index,
                    child: Icon(Icons.check, color: Colors.white),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      setState(() => indexColor = index);
                    },
                    child: _colorTile(index),
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              colors.length ~/ 2,
              (newIndex) {
                int index = newIndex + colors.length ~/ 2;
                if (indexColor == index) {
                  return _colorTile(
                    index,
                    child: Icon(Icons.check, color: Colors.white),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      setState(() => indexColor = index);
                    },
                    child: _colorTile(index),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _colorTile(int index, {Widget child}) {
    return Container(
      height: (MediaQuery.of(context).size.width - 60) / 6,
      width: (MediaQuery.of(context).size.width - 60) / 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(
          int.parse(colors[index]),
        ),
      ),
      child: child ?? null,
    );
  }
}
