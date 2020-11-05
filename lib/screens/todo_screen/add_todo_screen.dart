import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/image_viewer.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/models/template_todo.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/firestore/firestore_methods.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/todo_screen/note_screen.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class AddTodoScreen extends StatefulWidget {
  final TemplateTodo templateTodo;

  const AddTodoScreen({Key key, this.templateTodo}) : super(key: key);
  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen>
    with SingleTickerProviderStateMixin, BlocCreator, FilterMixin {
  AnimationController animationController;
  Animation animation;
  Animation opacityAnimation;
  int indexColor = 0;
  int _imageSize = 0;
  int _audioSize = 0;

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
  List<bool> _categoryItems =
      List.generate(catagories.length, (index) => false);

  String _audioPath = '';
  String _audioCode = '';
  PriorityState _priority = PriorityState.Low;
  String _note = "[]";

  Directory appDocDirectory;
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  TodoBloc _todoBloc;
  FirebaseApi _repository;

  Future _openGallery() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    print("FILE SIZE BEFORE: " + imageFile.lengthSync().toString());
    print("FILE NAME: ${imageFile.name}");

    _repository.firestore.uploadFile(imageFile, type: FileType.image);

    if (imageFile != null) {
      images.add(base64Encode(imageFile.readAsBytesSync()));
      _imageSize += imageFile.lengthSync();
      imageFileList.add(imageFile.readAsBytesSync());
    }
  }

  Future _openCamera() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    print("FILE SIZE BEFORE: ${imageFile.path}");
    print("FILE NAME: ${imageFile.name}");

    await _repository.firestore.uploadFile(imageFile, type: FileType.image);

    if (imageFile != null) {
      images.add(base64Encode(imageFile.readAsBytesSync()));
      _imageSize += imageFile.lengthSync();
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
          SnackBar(
            content: Text('You must accept permissions'.tr),
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
    _audioSize = _audioFile.lengthSync();
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

    if (widget.templateTodo != null) {
      _categoryItems = widget.templateTodo.categoryItems ??
          List.generate(catagories.length, (index) => false);
      indexColor = widget.templateTodo.color ?? 0;
      _note = widget.templateTodo.note.vi ?? "[]";
      _priority = widget.templateTodo.priorityState ?? PriorityState.Low;
    }

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
    print("IMAGE TOTAL: $_imageSize");
    print("AUDIO TOTAL: $_audioSize");
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 5, top: 10),
      child: Text(
        title.tr,
        style: NotemonTextStyle.kNormalStyle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildNote() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              "Note".tr,
              style: NotemonTextStyle.kNormalStyle
                  .copyWith(color: Colors.grey[600]),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 25),
            color: colors.parseColor(indexColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteScreen(
                    noteMode: NoteMode.add,
                    note: _note.parseNote(),
                    themeColor: colors.parseColor(indexColor),
                    onNoteSaved: (String newNote) => _note = newNote,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @deprecated
  @override
  Widget build(BuildContext context) {
    if (_isInitWidget == false) {
      _todoBloc = findBloc<TodoBloc>();
      _repository = findBloc<FirebaseApi>();
      _isInitWidget = true;
    }

    return Theme(
      data: Theme.of(context)
          .copyWith(accentColor: colors.parseColor(indexColor)),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: _buildAddTodoButton(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTodoNameTextField(),
                  _buildNote(),
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

  @deprecated
  Row _buildMicrophonePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            if (await FlutterAudioRecorder.hasPermissions) {
              if (_isRecording == false) {
                _start();
              } else {
                _stop();
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: colors.parseColor(indexColor),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(
              _isRecording == false ? SimpleLineIcons.microphone : Icons.stop,
              size: 50,
              color: colors.parseColor(indexColor),
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
                        activeTrackColor: colors.parseColor(indexColor),
                        inactiveTrackColor: Colors.grey[350],
                        trackHeight: 3,
                        thumbColor: colors.parseColor(indexColor),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 4,
                        ),
                        overlayColor:
                            colors.parseColor(indexColor).withOpacity(0.3),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 4,
                        ),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 140,
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
                            color: colors.parseColor(indexColor),
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
                            color: colors.parseColor(indexColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No files'.tr,
                      style: NotemonTextStyle.kTitleStyle
                          .copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Row _buildCameraPicker(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _cameraButton(
          onTap: () {
            if (isExpandCamera == false) {
              animationController.forward();
              setState(() => isExpandCamera = true);
            } else {
              animationController.reverse();
              setState(() => isExpandCamera = false);
            }
          },
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
                  setState(() {
                    isExpandCamera = false;
                  });
                },
                iconData: SimpleLineIcons.picture,
              )
            : Container(),
        imageFileList.isEmpty
            ? isExpandCamera == true
                ? Container()
                : Expanded(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: opacityAnimation.value,
                        duration: animationController.duration,
                        child: Text(
                          'No files'.tr,
                          style: NotemonTextStyle.kTitleStyle
                              .copyWith(color: Colors.grey),
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
              color: colors.parseColor(indexColor),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
            iconData,
            color: colors.parseColor(indexColor),
            size: 50,
          ),
        ),
      ),
    );
  }

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
            style: NotemonTextStyle.kNormalStyle.copyWith(
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
    return Column(children: [
      ...List.generate(
        catagories.length ~/ 3,
        (index) {
          int startIndex = index * 3;
          return Padding(
            padding: EdgeInsets.only(bottom: startIndex == 6 ? 0 : 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (index) {
                  index += startIndex;
                  String category = catagories[index]["name"];
                  return GestureDetector(
                    onTap: () {
                      setState(
                          () => _categoryItems[index] = !_categoryItems[index]);
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
            ),
          );
        },
      ),
    ]);
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
                              color: colors.parseColor(indexColor),
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
                              color: colors.parseColor(indexColor),
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
          );
        },
      );

  Widget _cameraButton({VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.parseColor(indexColor),
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
                  color: colors.parseColor(indexColor),
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
                  color: colors.parseColor(indexColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoNameTextField() => AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colors.parseColor(indexColor),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _todoEditting,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: 'To-do name'.tr,
            labelStyle:
                NotemonTextStyle.kNormalStyle.copyWith(color: Colors.grey),
            focusColor: TodoColors.lightOrange,
            border: InputBorder.none,
          ),
        ),
      );

  Widget _buildAddTodoButton(BuildContext context) => GestureDetector(
        onTap: () async {
          if (_isRecording == false) {
            isCreate = true;
            String id = Uuid().v1();
            Todo _todo = Todo(
              id: id,
              timestamp: Timestamp.now().toDate(),
              content: _todoEditting.text,
              state: "notDone",
              images: images.toString(),
              color: indexColor,
              audioPath: _haveRecord ? _audioPath : '',
              audioCode: _haveRecord ? _audioCode : '',
              catagories: _categoryItems,
              priority: _priority,
              note: _note,
            );
            _todoBloc.add(AddTodoEvent(todo: _todo));

            if (await checkConnection())
              _repository.firebase.updateTodoToFirebase(_todo);

            Get.back();
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
                  ' ${"Add to-do".tr}',
                  style: NotemonTextStyle.kNormalStyle
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          color: colors.parseColor(indexColor),
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
                  style: NotemonTextStyle.kTitleStyle,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colors.parseColor(indexColor),
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
      );
}
