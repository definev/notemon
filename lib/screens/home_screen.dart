import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/component.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/pokemon_screen/all_pokemon_screen.dart';
import 'package:gottask/screens/task_screen/task_export.dart';
import 'package:gottask/screens/todo_screen/add_todo_screen.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, BlocCreator {
  bool _isInit = false;
  int _updateCounter = 0;

  Map<String, dynamic> _todoFilterMap = {
    "priority": PriorityState.All,
    "todoFilter": List.generate(catagories.length, (index) => false),
  };

  Map<String, dynamic> _taskFilterMap = {
    "priority": PriorityState.All,
    "taskFilter": List.generate(catagories.length, (index) => false),
  };

  Map<String, bool> _isLoading = {
    'todo': false,
    'task': false,
    'pokemonState': false,
    'starPoint': false,
    'favouritePokemon': false,
  };

  ConnectionStatusSingleton connectionStatus;
  StreamSubscription<bool> _intenetStreamSubscription;

  TodoBloc _todoBloc;
  TaskBloc _taskBloc;
  AllPokemonBloc _allPokemonBloc;
  StarBloc _starBloc;
  FavouritePokemonBloc _favouritePokemonBloc;

  FirebaseApi _repository;

  _modalBottomSheetMenu() =>
      showModalBottomSheet(context: context, builder: (_) => AddTodoScreen());

  _updateTodos() async {
    if (_repository.firebase.user == null)
      await _repository.firebase.initUser();
    if (_todoBloc.todoList != null) {
      /// [Delete key setup]
      List<String> _deleteKey = List<String>.from(_todoBloc.deleteTodoKey);
      List<String> _deleteKeyInServer =
          await _repository.firebase.getDeleteTodoKey();
      List<String> _finalDeleteKey = [..._deleteKey, ..._deleteKeyInServer];
      _finalDeleteKey = LinkedHashSet<String>.from(_finalDeleteKey).toList();
      _deleteKey = [];
      for (String key in _finalDeleteKey) {
        if (!_deleteKeyInServer.contains(key)) {
          _deleteKey.add(key);
        }
      }

      await _repository.firebase.setDeleteTodoKey(_deleteKey);

      /// [Remove todo if todo.id == deleteKey on server]
      List<Todo> _todoListServer = [];

      _repository.firebase.getAllTodo().then(
        (todoListServerRaw) async {
          _todoListServer = todoListServerRaw;
          List<Todo>.from(todoListServerRaw).forEach((todo) async {
            if (_deleteKey.contains(todo.id)) {
              _todoListServer.remove(todo);
              await _repository.firebase.deleteTodoOnFirebase(todo);
            }
          });
          List<Todo> _todoListLocal = _todoBloc.todoList;
          List<Todo>.from(_todoBloc.todoList).forEach((todo) {
            if (_finalDeleteKey.contains(todo.id)) {
              _todoListLocal.remove(todo);
              _todoBloc.add(DeleteTodoEvent(todo: todo, addDeleteKey: false));
            }
          });
          List<Todo> _todoListFinal = _todoListLocal;
          List<Todo> _todoListAddIn = [];

          for (int i = 0; i < _todoListServer.length; i++) {
            if (!_todoListLocal.contains(_todoListServer[i])) {
              _todoListFinal.add(_todoListServer[i]);
              _todoListAddIn.add(_todoListServer[i]);
            }
          }

          await _repository.firebase.uploadAllTodoToFirebase(_todoListFinal);
          _todoListAddIn.forEach(
            (todo) => _todoBloc.add(AddTodoEvent(todo: todo)),
          );
        },
      );
    }
  }

  _updateTasks() async {
    if (_repository.firebase.user == null)
      await _repository.firebase.initUser();
    if (_taskBloc.taskList != null) {
      /// [Delete key setup]
      List<String> _deleteKey = List<String>.from(_taskBloc.deleteTaskKey);
      List<String> _deleteKeyInServer =
          await _repository.firebase.getDeleteTaskKey();
      List<String> _finalDeleteKey = [..._deleteKey, ..._deleteKeyInServer];
      _finalDeleteKey = LinkedHashSet<String>.from(_finalDeleteKey).toList();
      _deleteKey = [];
      for (String key in _finalDeleteKey) {
        if (!_deleteKeyInServer.contains(key)) {
          _deleteKey.add(key);
        }
      }

      await _repository.firebase.setDeleteTaskKey(_deleteKey);

      /// [Remove task if task.id == deleteKey on server]
      List<Task> _taskListServer = [];

      _repository.firebase.getAllTask().then(
        (taskListServerRaw) async {
          _taskListServer = taskListServerRaw;
          List<Task>.from(taskListServerRaw).forEach((task) async {
            if (_deleteKey.contains(task.id)) {
              _taskListServer.remove(task);
              await _repository.firebase.deleteTaskOnFirebase(task);
            }
          });
          List<Task> _taskListLocal = _taskBloc.taskList;
          List<Task>.from(_taskBloc.taskList).forEach((task) {
            if (_finalDeleteKey.contains(task.id)) {
              _taskListLocal.remove(task);
              _taskBloc.add(DeleteTaskEvent(task: task, addDeleteKey: false));
            }
          });
          List<Task> _taskListFinal = _taskListLocal;
          List<Task> _taskListAddIn = [];

          for (int i = 0; i < _taskListServer.length; i++) {
            if (!_taskListLocal.contains(_taskListServer[i])) {
              _taskListFinal.add(_taskListServer[i]);
              _taskListAddIn.add(_taskListServer[i]);
            }
          }

          await _repository.firebase.uploadAllTaskToFirebase(_taskListFinal);
          _taskListAddIn.forEach(
            (task) => _taskBloc.add(AddTaskEvent(task: task)),
          );
        },
      );
    }
  }

  _updateStarpoint() async {
    Map<String, int> _onlineStarpoint =
        await _repository.firebase.getOnlineStarpoint();
    Map<String, int> _finalStarpoint = {
      "addStar": _starBloc.addStar,
      "loseStar": _starBloc.loseStar,
    };

    if (_onlineStarpoint["addStar"] != _finalStarpoint["addStar"] ||
        _onlineStarpoint["loseStar"] != _finalStarpoint["loseStar"]) {
      _onlineStarpoint.forEach((key, value) {
        if (_finalStarpoint[key] < value) _finalStarpoint[key] = value;
      });

      print("DIFF!!!");

      _repository.firebase.updateStarpoint(_finalStarpoint);
      _starBloc.add(SetStarEvent(starMap: _finalStarpoint));
    }
  }

  _updatePokemonStates() async {
    try {
      List<PokemonState> _onlinePokemonStateList =
          await _repository.firebase.getAllPokemonState();
      for (int i = 0; i < _allPokemonBloc.pokemonStateList.length; i++) {
        if (_onlinePokemonStateList[i].state !=
            _allPokemonBloc.pokemonStateList[i].state) {
          if (_onlinePokemonStateList[i].state == 1) {
            //Update in local
            _allPokemonBloc.add(UpdatePokemonStateEvent(
                pokemonState: _onlinePokemonStateList[i]));
          } else {
            //Update in online
            _repository.firebase.updatePokemonStateToFirebase(
                _allPokemonBloc.pokemonStateList[i]);
          }
        }
      }
    } catch (e) {}
  }

  _updateFavouritePokemon() async {
    FavouritePokemon _favPokemon =
        await _repository.firebase.getFavouritePokemon();

    if (_favouritePokemonBloc.favouritePokemon != _favPokemon.pokemon) {
      _repository.firebase
          .updateFavouritePokemon(_favouritePokemonBloc.favouritePokemon);
    }
  }

  _updateDatabase() async {
    print("_updateCounter!!");

    setState(() {
      _isLoading['todo'] = true;
      _isLoading['task'] = true;
      _isLoading['pokemonState'] = true;
      _isLoading['starPoint'] = true;
      _isLoading['favouritePokemon'] = true;
    });
    await _updateTodos();
    await _updateTasks();
    await _updateStarpoint();
    await _updatePokemonStates();
    await _updateFavouritePokemon();
    setState(() {
      _isLoading['todo'] = false;
      _isLoading['task'] = false;
      _isLoading['pokemonState'] = false;
      _isLoading['starPoint'] = false;
      _isLoading['favouritePokemon'] = false;
    });
  }

  _updateTodosFromOtherDevice(List<Todo> todoList) async {
    List<Todo> _todoListLocal = List<Todo>.from(_todoBloc.todoList);
    List<Todo> _addTodoLocal = [];
    for (Todo todo in todoList) {
      for (int i = 0; i <= _todoListLocal.length; i++) {
        if (!_todoListLocal.contains(todo)) {
          _addTodoLocal.add(todo);
        } else {
          int index =
              _todoListLocal.indexWhere((todoLocal) => todo == todoLocal);

          if (todo.hashCode != _todoListLocal[index].hashCode) {
            _todoBloc.add(EditTodoEvent(todo: todo));
          }
        }
      }
    }

    for (Todo todo in _addTodoLocal) {
      _todoBloc.add(AddTodoEvent(todo: todo));
    }

    List<String> _deleteKey = await _repository.firebase.getDeleteTodoKey();
    _todoListLocal = List<Todo>.from(_todoBloc.todoList);
    for (Todo todo in _todoListLocal) {
      if (_deleteKey.contains(todo.id)) {
        _todoBloc.add(
          DeleteTodoEvent(
            todo: todo,
            addDeleteKey: true,
          ),
        );
      }
    }
  }

  _updateTasksFromOtherDevice(List<Task> taskList) async {
    List<Task> _taskListLocal = List<Task>.from(_taskBloc.taskList);
    List<Task> _addTaskLocal = [];
    for (Task task in taskList) {
      for (int i = 0; i <= _taskListLocal.length; i++) {
        if (!_taskListLocal.contains(task)) {
          _addTaskLocal.add(task);
        } else {
          int index =
              _taskListLocal.indexWhere((taskLocal) => task == taskLocal);

          if (task.hashCode != _taskListLocal[index].hashCode) {
            _taskBloc.add(EditTaskEvent(task: task));
          }
        }
      }
    }

    for (Task task in _addTaskLocal) {
      _taskBloc.add(AddTaskEvent(task: task));
    }

    List<String> _deleteKey = await _repository.firebase.getDeleteTaskKey();
    _taskListLocal = List<Task>.from(_taskBloc.taskList);
    for (Task task in _taskListLocal) {
      if (_deleteKey.contains(task.id)) {
        _taskBloc.add(
          DeleteTaskEvent(task: task, addDeleteKey: true),
        );
      }
    }
  }

  _updateStarpointFromOtherDevice(Map<String, dynamic> _onlineStarpoint) {
    Map<String, int> _finalStarpoint = {
      "addStar": _starBloc.addStar,
      "loseStar": _starBloc.loseStar,
    };

    if (_onlineStarpoint["addStar"] != _finalStarpoint["addStar"] ||
        _onlineStarpoint["loseStar"] != _finalStarpoint["loseStar"]) {
      _onlineStarpoint.forEach((key, value) {
        if (_finalStarpoint[key] < value) {
          _finalStarpoint[key] = value;
        }
      });

      _starBloc.add(SetStarEvent(starMap: _finalStarpoint));
    }
  }

  _updatePokemonStateFromOtherDevice(
      List<PokemonState> _onlinePokemonStateList) async {
    if (_allPokemonBloc.pokemonStateList != null &&
        _onlinePokemonStateList != null) {
      for (int i = 0; i < _allPokemonBloc.pokemonStateList.length; i++) {
        if (_onlinePokemonStateList[i].state !=
            _allPokemonBloc.pokemonStateList[i].state) {
          _allPokemonBloc.add(
            UpdatePokemonStateEvent(pokemonState: _onlinePokemonStateList[i]),
          );
        }
      }
    } else {
      _onlinePokemonStateList.forEach((state) {
        _allPokemonBloc.add(UpdatePokemonStateEvent(pokemonState: state));
      });
    }
  }

  _updateFavouritePokemonFromOtherDevice(
      FavouritePokemon _onlineFavouritePokemon) async {
    if (_onlineFavouritePokemon.pokemon !=
        _favouritePokemonBloc.favouritePokemon) {
      _favouritePokemonBloc
          .add(UpdateFavouritePokemonEvent(_onlineFavouritePokemon.pokemon));
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: appId);
    setLoadAdsInfirst(false);
    connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _intenetStreamSubscription =
        connectionStatus.connectionChangeController.stream.listen(
      (hasInternet) async {
        if (hasInternet) {
          print(_updateCounter);

          if (this._updateCounter == 0) {
            setState(() => _updateCounter += 1);

            _updateDatabase();
          }
        } else {
          _updateCounter = 0;
          print("OFF: $_updateCounter");
        }
      },
    );
  }

  @override
  void dispose() {
    _intenetStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) {
      /// Find bloc in provider
      _todoBloc = findBloc<TodoBloc>();
      _taskBloc = findBloc<TaskBloc>();
      _allPokemonBloc = findBloc<AllPokemonBloc>();
      _starBloc = findBloc<StarBloc>();
      _repository = findBloc<FirebaseApi>();
      _repository.firebase.initUser().then((_) => setState(() {}));
      _favouritePokemonBloc = findBloc<FavouritePokemonBloc>();

      /// add initState
      _todoBloc.add(InitTodoEvent());
      _taskBloc.add(InitTaskEvent());
      _allPokemonBloc.add(InitAllPokemonEvent());
      _starBloc.add(InitStarBloc());
      _favouritePokemonBloc.add(InitFavouritePokemonEvent());
      _isInit = true;
    }
    if (_repository.firebase.user == null) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.25, 0.463, 0.2, 0.7, 0.9],
              colors: [
                TodoColors.scaffoldWhite,
                TodoColors.scaffoldWhite,
                TodoColors.scaffoldWhite,
                TodoColors.scaffoldWhite,
                Color(0xFFFEDCBA),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.25, 0.463, 0.2, 0.7, 0.9],
            colors: [
              TodoColors.scaffoldWhite,
              TodoColors.scaffoldWhite,
              TodoColors.scaffoldWhite,
              TodoColors.scaffoldWhite,
              Color(0xFFFEDCBA),
            ],
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.transparent,
          body: StreamBuilder<bool>(
            stream: connectionStatus.connectionChangeController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                connectionStatus.hasConnection = null;
                connectionStatus.checkOutConnection();
                return Center(
                  child: LoadingJumpingLine.circle(
                    backgroundColor: TodoColors.deepPurple,
                  ),
                );
              }
              return IndexedStack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildOfflineHeader(),
                      _buildOfflinePetCollection(),
                      _buildOfflineTaskHeader(),
                      _buildOfflineTask(),
                      _buildOfflineTodoHeader(),
                      _buildOfflineTodo(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildOnlineHeader(snapshot.data),
                      _buildOnlinePetCollection(snapshot.data),
                      _buildOnlineTaskHeader(),
                      _buildOnlineTask(snapshot.data),
                      _buildOnlineTodoHeader(),
                      _buildOnlineTodo(snapshot.data),
                    ],
                  ),
                ],
                index: snapshot.data == false || snapshot.data == null ? 0 : 1,
              );
            },
          ),
        ),
      ),
    );
  }

  /// [Online]

  Widget _buildOnlineHeader(bool isOnline) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 15,
        top: 5,
      ),
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                      stream: _repository.firebase.firestore
                          .collection('databases')
                          .document(_repository.firebase.user.uid)
                          .collection('favouritePokemon')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: LoadingJumpingLine.circle(
                                  size: 15,
                                  backgroundColor: TodoColors.deepPurple,
                                ),
                              ),
                            ),
                          );
                        }
                        if (snapshot.data == null) {
                          return GestureDetector(
                            onTap: () async {
                              await compareTime();

                              Get.to(
                                BlocProvider<HandSideBloc>.value(
                                  value: HandSideBloc(),
                                  child: AllPokemonScreen(currentPokemon: 0),
                                ),
                              );
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  MaterialCommunityIcons.pokeball,
                                  size: 30,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          );
                        }

                        if (snapshot.data.documents.isEmpty) {
                          _repository.firebase.updateFavouritePokemon(-1);
                          return Container();
                        }

                        FavouritePokemon _favouritePokemon =
                            FavouritePokemon.fromMap(
                                snapshot.data.documents[0].data);

                        if (!_isLoading["favouritePokemon"] && isOnline)
                          _updateFavouritePokemonFromOtherDevice(
                              _favouritePokemon);

                        if (_favouritePokemon.pokemon != -1) {
                          return GestureDetector(
                            onTap: () async {
                              await compareTime();
                              Get.to(
                                BlocProvider<HandSideBloc>.value(
                                  value: HandSideBloc(),
                                  child: AllPokemonScreen(
                                    currentPokemon: _favouritePokemon.pokemon,
                                  ),
                                ),
                              );
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  pokedex[_favouritePokemon.pokemon].imageUrl,
                                  height: 30,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              await compareTime();
                              Get.to(
                                BlocProvider<HandSideBloc>.value(
                                  value: HandSideBloc(),
                                  child: AllPokemonScreen(currentPokemon: 0),
                                ),
                              );
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  MaterialCommunityIcons.pokeball,
                                  size: 30,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              StreamBuilder<DocumentSnapshot>(
                                stream: _repository.firebase.firestore
                                    .collection('databases')
                                    .document(_repository.firebase.user.uid)
                                    .collection('starPoint')
                                    .document('star')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Text(
                                      '0 ',
                                      style: kNormalStyle,
                                    );
                                  }
                                  if (snapshot.data.data == null) {
                                    _repository.firebase.updateStarpoint(
                                        {"addStar": 0, "loseStar": 0});
                                    return Text(
                                      '0 ',
                                      style: kNormalStyle,
                                    );
                                  }
                                  Starpoint _starPoint =
                                      Starpoint.fromMap(snapshot.data.data);
                                  if (!_isLoading["starPoint"] && isOnline)
                                    _updateStarpointFromOtherDevice(
                                        snapshot.data.data);
                                  return Text(
                                    '${_starPoint.star} ',
                                    style: kNormalStyle,
                                  );
                                },
                              ),
                              Image.asset(
                                'assets/png/star.png',
                                height: 13,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    getTimeNow(),
                    style:
                        kBigTitleStyle.copyWith(color: const Color(0xFF061058)),
                  ),
                  Text(
                    '${DateFormat.yMMMEd(Get.locale.toString()).format(DateTime.now())}',
                    style: kNormalStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlinePetCollection(bool isOnline) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.amber.withOpacity(0.08),
            ),
          ],
        ),
        child: Container(
          height: 85,
          width: MediaQuery.of(context).size.width - 20,
          padding: const EdgeInsets.all(2),
          child: StreamBuilder<QuerySnapshot>(
            stream: _repository.firebase.firestore
                .collection('databases')
                .document(_repository.firebase.user.uid)
                .collection('pokemonStates')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text('${"Loading".tr} ...'),
                );
              }
              if (snapshot.data.documents.isEmpty) {
                List<PokemonState> _pokemonStates = [];
                pokedex.forEach((pokemon) {
                  _pokemonStates.add(
                    PokemonState(
                      name: pokemon.name,
                      state: 0,
                    ),
                  );
                });
                _repository.firebase
                    .uploadAllPokemonStateToFirebase(_pokemonStates);
                return Center(
                  child: Text('${"Loading".tr} ...'),
                );
              }
              List<PokemonState> _pokemonStateList = [];
              snapshot.data.documents.forEach((map) =>
                  _pokemonStateList.add(PokemonState.fromMap(map.data)));

              if (!_isLoading["pokemonState"] && isOnline)
                _updatePokemonStateFromOtherDevice(_pokemonStateList);

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                addRepaintBoundaries: true,
                scrollDirection: Axis.horizontal,
                itemCount: _pokemonStateList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await compareTime();

                      Get.to(
                        BlocProvider<HandSideBloc>.value(
                          value: HandSideBloc(),
                          child: AllPokemonScreen(
                            currentPokemon: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 56.2,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 1.5,
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 0.5,
                              spreadRadius: 0.5,
                              color: Colors.black12,
                            ),
                          ]),
                      margin: index < pokedex.length - 1
                          ? const EdgeInsets.only(
                              right: 6.2,
                              bottom: 3,
                              top: 3,
                            )
                          : const EdgeInsets.only(
                              right: 1,
                              bottom: 3,
                              top: 3,
                            ),
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Image.asset(
                                pokedex[index].imageUrl,
                                height: 60,
                                width: 60,
                                color: colorStateOfPokemon(
                                  _pokemonStateList[index].state,
                                ),
                                colorBlendMode: colorBlendStateOfPokemon(
                                  _pokemonStateList[index].state,
                                ),
                              ),
                            ),
                            if (_pokemonStateList[index].state == 0)
                              Center(
                                child: Icon(
                                  AntDesign.question,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Padding _buildOnlineTodoHeader() => Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'To-do list'.tr,
              style: kTitleStyle,
            ),
            _todoFilter(),
          ],
        ),
      );

  Row _todoFilter() {
    return Row(
      children: [
        Row(
          children: [
            Row(
              children: [
                Text(
                  shortPriorityList[_todoFilterMap['priority'].index].tr,
                  style: kBigTitleStyle.copyWith(
                    fontFamily: "Source_Sans_Pro",
                    fontSize: 18,
                    color: setPriorityColor(
                        priorityList[_todoFilterMap['priority'].index]),
                  ),
                ),
                Container(
                  height: 25,
                  width: 1,
                  margin: const EdgeInsets.only(left: 8),
                  color: setPriorityColor(
                      priorityList[_todoFilterMap['priority'].index]),
                ),
              ],
            ),
            if (_todoFilterMap['todoFilter'].contains(true))
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _todoFilterMap['todoFilter'].length,
                      (index) {
                        if (_todoFilterMap['todoFilter'][index]) {
                          return Container(
                            height: 20,
                            child: Column(
                              children: [
                                Container(
                                  height: 10,
                                  width: 3,
                                  color: TodoColors.lightGreen,
                                ),
                                Container(
                                  height: 10,
                                  width: 3,
                                  color: TodoColors.scaffoldWhite,
                                ),
                              ],
                            ),
                          );
                        }
                        return Container(
                          height: 20,
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: 3,
                                color: TodoColors.scaffoldWhite,
                              ),
                              Container(
                                height: 10,
                                width: 3,
                                color: TodoColors.groundPink,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: Duration(milliseconds: 600),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(left: 10, right: 5),
              child: InkWell(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: Icon(
                    (!_todoFilterMap['todoFilter'].contains(true))
                        ? Icons.filter_list
                        : Icons.edit,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                onTap: () {
                  List<bool> _filterCategoryClone = List.generate(
                    _todoFilterMap['todoFilter'].length,
                    (index) => _todoFilterMap['todoFilter'][index],
                  );
                  PriorityState _priorityStateClone =
                      _todoFilterMap['priority'];

                  showModalBottomSheet(
                    context: context,
                    builder: (context) => FilterPicker(
                      nameFilter: "To-do",
                      priority: _priorityStateClone,
                      initCategory: _filterCategoryClone,
                      onCompeleted: (catagories, priority) {
                        setState(() {
                          _todoFilterMap['todoFilter'] = catagories;
                          _todoFilterMap['priority'] = priority;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Container(
          width: 25,
          height: 25,
          margin: const EdgeInsets.only(right: 15),
          child: RawMaterialButton(
            fillColor: TodoColors.deepPurple,
            shape: const CircleBorder(),
            elevation: 0.5,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: _modalBottomSheetMenu,
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineTodo(bool isOnline) => Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _repository.firebase.firestore
              .collection('databases')
              .document(_repository.firebase.user.uid)
              .collection('todos')
              .orderBy('priority')
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting ||
                _isLoading['todo'] == true) {
              return SizedBox(
                height: kListViewHeight + 2,
                width: double.infinity,
                child: Center(
                  child: LoadingJumpingLine.circle(
                    size: 30,
                    backgroundColor: TodoColors.deepPurple,
                  ),
                ),
              );
            }
            if (snapshots.data != null) {
              List<Todo> _todoList = [];
              snapshots.data.documents.forEach(
                  (todo) => _todoList.add(Todo.fromFirebaseMap(todo.data)));
              _todoList = todoFilterProcess(_todoList);

              if (!_isLoading['todo'] && isOnline)
                _updateTodosFromOtherDevice(_todoList);
              if (_todoList.isEmpty) {
                return Center(
                  child: Text(
                    'Empty to-do'.tr,
                    style: kNormalStyle,
                  ),
                );
              } else {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) => TodoTile(
                    todo: _todoList[index],
                    key: UniqueKey(),
                  ),
                );
              }
            }

            return Center(
              child: Text(
                'Empty to-do'.tr,
                style: kNormalStyle,
              ),
            );
          },
        ),
      );

  Widget _buildOnlineTaskHeader() => Padding(
        padding: const EdgeInsets.only(
          left: 15,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Task list'.tr,
              style: kTitleStyle,
            ),
            _taskFilter(),
          ],
        ),
      );

  Row _taskFilter() {
    return Row(
      children: [
        Row(
          children: [
            Row(
              children: [
                Text(
                  priorityList[_taskFilterMap['priority'].index].tr,
                  style: kBigTitleStyle.copyWith(
                    fontFamily: "Source_Sans_Pro",
                    fontSize: 18,
                    color: setPriorityColor(
                        priorityList[_taskFilterMap['priority'].index]),
                  ),
                ),
                Container(
                  height: 25,
                  width: 1,
                  margin: const EdgeInsets.only(left: 8),
                  color: setPriorityColor(
                      priorityList[_taskFilterMap['priority'].index]),
                ),
              ],
            ),
            if (_taskFilterMap['taskFilter'].contains(true))
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _taskFilterMap['taskFilter'].length,
                      (index) {
                        if (_taskFilterMap['taskFilter'][index]) {
                          return Container(
                            height: 20,
                            child: Column(
                              children: [
                                Container(
                                  height: 10,
                                  width: 3,
                                  color: TodoColors.lightGreen,
                                ),
                                Container(
                                  height: 10,
                                  width: 3,
                                  color: TodoColors.scaffoldWhite,
                                ),
                              ],
                            ),
                          );
                        }
                        return Container(
                          height: 20,
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: 3,
                                color: TodoColors.scaffoldWhite,
                              ),
                              Container(
                                height: 10,
                                width: 3,
                                color: TodoColors.groundPink,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: Duration(milliseconds: 600),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(left: 10, right: 5),
              child: InkWell(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: Icon(
                    (!_taskFilterMap['taskFilter'].contains(true))
                        ? Icons.filter_list
                        : Icons.edit,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                onTap: () {
                  List<bool> _filterCategoryClone = List.generate(
                    _taskFilterMap['taskFilter'].length,
                    (index) => _taskFilterMap['taskFilter'][index],
                  );
                  PriorityState _priorityStateClone =
                      _taskFilterMap['priority'];

                  showModalBottomSheet(
                    context: context,
                    builder: (context) => FilterPicker(
                      key: UniqueKey(),
                      nameFilter: "Task",
                      priority: _priorityStateClone,
                      initCategory: _filterCategoryClone,
                      onCompeleted: (catagories, priority) => setState(() {
                        _taskFilterMap['taskFilter'] = catagories;
                        _taskFilterMap['priority'] = priority;
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Container(
          width: 25,
          height: 25,
          margin: const EdgeInsets.only(right: 15),
          child: RawMaterialButton(
            fillColor: TodoColors.deepPurple,
            shape: const CircleBorder(),
            elevation: 0.5,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => Get.to(AddTaskScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineTask(bool isOnline) {
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.firebase.firestore
          .collection('databases')
          .document(_repository.firebase.user.uid)
          .collection('tasks')
          .orderBy('priority')
          .snapshots(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting ||
            _isLoading['task'] == true) {
          return SizedBox(
            height: kListViewHeight + 2,
            width: double.infinity,
            child: Center(
              child: LoadingJumpingLine.circle(
                size: 30,
                backgroundColor: TodoColors.deepPurple,
              ),
            ),
          );
        }
        if (snapshots.data == null) {
          _repository.firebase.uploadAllTaskToFirebase(_taskBloc.taskList);
          return SizedBox(
            height: kListViewHeight + 2,
            width: double.infinity,
            child: Center(
              child: Text(
                'Empty task'.tr,
                style: kNormalStyle,
              ),
            ),
          );
        } else {
          if (snapshots.data.documents.isEmpty) {
            return SizedBox(
              height: kListViewHeight + 2,
              width: double.infinity,
              child: Center(
                child: Text(
                  'Empty task'.tr,
                  style: kNormalStyle,
                ),
              ),
            );
          } else {
            List<Task> _taskList = [];
            snapshots.data.documents.forEach(
                (maps) => _taskList.add(Task.fromFirebaseMap(maps.data)));
            _taskList = taskFilterProcess(_taskList);

            if (!_isLoading['task'] && isOnline)
              _updateTasksFromOtherDevice(_taskList);

            if (_taskList.isEmpty) {
              return SizedBox(
                height: kListViewHeight + 2,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Empty task'.tr,
                    style: kNormalStyle,
                  ),
                ),
              );
            }
            return SizedBox(
              height: kListViewHeight + 2,
              width: double.infinity,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _taskList.length + 1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == _taskList.length) {
                    return Center(
                      child: GestureDetector(
                        onTap: () => Get.to(AddTaskScreen()),
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          height: kListViewHeight,
                          width: kListViewHeight,
                          child: DottedBorder(
                            radius: const Radius.circular(30),
                            borderType: BorderType.RRect,
                            dashPattern: const [20, 5, 20, 5],
                            color: Colors.grey,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Center(
                        child: TaskTile(
                          removeAds: false,
                          task: _taskList[index],
                          key: UniqueKey(),
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: TaskTile(
                      removeAds: false,
                      task: _taskList[index],
                      key: UniqueKey(),
                    ),
                  );
                },
              ),
            );
          }
        }
      },
    );
  }

  /// [Offline]

  Widget _buildOfflineHeader() => Padding(
        padding: const EdgeInsets.only(
          right: 15,
          top: 5,
        ),
        child: Stack(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: <Widget>[
                      BlocBuilder<FavouritePokemonBloc, FavouritePokemonState>(
                        bloc: _favouritePokemonBloc,
                        builder: (context, state) {
                          if (state is FavouritePokemonInitial) {
                            return Container();
                          }
                          if (state is FavouritePokemonLoaded) {
                            if (state.pokemon == null) return Container();

                            if (state.pokemon != -1) {
                              return GestureDetector(
                                onTap: () async {
                                  await compareTime();
                                  Get.to(
                                    BlocProvider<HandSideBloc>.value(
                                      value: HandSideBloc(),
                                      child: AllPokemonScreen(
                                        currentPokemon: state.pokemon,
                                      ),
                                    ),
                                  );
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      pokedex[state.pokemon].imageUrl,
                                      height: 30,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () async {
                                  await compareTime();

                                  Get.to(
                                    BlocProvider<HandSideBloc>.value(
                                      value: HandSideBloc(),
                                      child:
                                          AllPokemonScreen(currentPokemon: 0),
                                    ),
                                  );
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      MaterialCommunityIcons.pokeball,
                                      size: 30,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                          return Container();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                BlocBuilder<StarBloc, StarState>(
                                  bloc: _starBloc,
                                  builder:
                                      (BuildContext context, StarState state) {
                                    if (state is StarLoaded) {
                                      return Text('${state.currentStar} ',
                                          style: kNormalStyle);
                                    }
                                    return Text(
                                      '0 ',
                                      style: kNormalStyle,
                                    );
                                  },
                                ),
                                Image.asset(
                                  'assets/png/star.png',
                                  height: 13,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      getTimeNow(),
                      style: kBigTitleStyle.copyWith(
                          color: const Color(0xFF061058)),
                    ),
                    Text(
                      '${DateFormat.yMMMEd().format(DateTime.now())}',
                      style: kNormalStyle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildOfflinePetCollection() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.amber.withOpacity(0.08),
              ),
            ],
          ),
          child: Container(
            height: 85,
            width: MediaQuery.of(context).size.width - 20,
            padding: const EdgeInsets.all(2),
            child: BlocBuilder<AllPokemonBloc, AllPokemonState>(
              bloc: _allPokemonBloc,
              builder: (context, state) {
                if (state is AllPokemonLoaded) {
                  if (state.pokemonStateList == null) Container();
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    addRepaintBoundaries: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.pokemonStateList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          await compareTime();

                          Get.to(
                            BlocProvider<HandSideBloc>.value(
                              value: HandSideBloc(),
                              child: AllPokemonScreen(
                                currentPokemon: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 56.2,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.deepPurple,
                                width: 1.5,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 0.5,
                                  spreadRadius: 0.5,
                                  color: Colors.black12,
                                ),
                              ]),
                          margin: index < pokedex.length - 1
                              ? const EdgeInsets.only(
                                  right: 6.2,
                                  bottom: 3,
                                  top: 3,
                                )
                              : const EdgeInsets.only(
                                  right: 1,
                                  bottom: 3,
                                  top: 3,
                                ),
                          padding: const EdgeInsets.all(5),
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Image.asset(
                                    pokedex[index].imageUrl,
                                    height: 60,
                                    width: 60,
                                    color: colorStateOfPokemon(
                                      state.pokemonStateList[index].state,
                                    ),
                                    colorBlendMode: colorBlendStateOfPokemon(
                                      state.pokemonStateList[index].state,
                                    ),
                                  ),
                                ),
                                if (state.pokemonStateList[index].state == 0)
                                  Center(
                                    child: Icon(
                                      AntDesign.question,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: Text('${"Loading".tr} ...'),
                );
              },
            ),
          ),
        ),
      );

  Padding _buildOfflineTodoHeader() => Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'To-do list'.tr,
              style: kTitleStyle,
            ),
            _todoFilter(),
          ],
        ),
      );

  Widget _buildOfflineTodo() => Expanded(
        child: BlocBuilder<TodoBloc, TodoState>(
          bloc: _todoBloc,
          builder: (context, state) {
            if (state is TodoLoaded) {
              if (state.todo.isEmpty) {
                return Center(
                  child: Text(
                    'Empty to-do'.tr,
                    style: kNormalStyle,
                  ),
                );
              } else {
                List<Todo> _todoList = state.todo;

                /// Sort todo by priority
                _todoList = todoPrioritySort(_todoList);
                _todoList = todoFilterProcess(_todoList);

                if (_todoList.length == 0) {
                  return Center(
                    child: Text(
                      'Empty to-do'.tr,
                      style: kNormalStyle,
                    ),
                  );
                }

                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) => TodoTile(
                    todo: _todoList[index],
                    key: UniqueKey(),
                  ),
                );
              }
            }
            return Center(
              child: Text(
                'Empty to-do'.tr,
                style: kNormalStyle,
              ),
            );
          },
        ),
      );

  Widget _buildOfflineTaskHeader() => Padding(
        padding: const EdgeInsets.only(
          left: 15,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Task list'.tr,
              style: kTitleStyle,
            ),
            _taskFilter(),
          ],
        ),
      );

  Widget _buildOfflineTask() => BlocBuilder<TaskBloc, TaskState>(
        bloc: _taskBloc,
        builder: (context, state) {
          if (state is TaskLoaded) {
            if (state.task.isEmpty) {
              return SizedBox(
                height: kListViewHeight + 2,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Empty task'.tr,
                    style: kNormalStyle,
                  ),
                ),
              );
            } else {
              List<Task> _taskList = state.task;
              _taskList = taskPrioritySort(_taskList);
              _taskList = taskFilterProcess(_taskList);

              if (_taskList.length == 0) {
                return SizedBox(
                  height: kListViewHeight + 2,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Empty task'.tr,
                      style: kNormalStyle,
                    ),
                  ),
                );
              }
              return SizedBox(
                height: kListViewHeight + 2,
                width: double.infinity,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _taskList.length + 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == _taskList.length) {
                      return Center(
                        key: UniqueKey(),
                        child: GestureDetector(
                          onTap: () => Get.to(AddTaskScreen()),
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            height: kListViewHeight,
                            width: kListViewHeight,
                            child: DottedBorder(
                              radius: const Radius.circular(30),
                              borderType: BorderType.RRect,
                              dashPattern: const [20, 5, 20, 5],
                              color: Colors.grey,
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Center(
                          key: UniqueKey(),
                          child: TaskTile(
                            removeAds: false,
                            task: _taskList[index],
                          ),
                        ),
                      );
                    }

                    return Center(
                      key: UniqueKey(),
                      child: TaskTile(
                        removeAds: false,
                        task: _taskList[index],
                      ),
                    );
                  },
                ),
              );
            }
          }
          return SizedBox(
            height: kListViewHeight + 2,
            width: double.infinity,
            child: Center(
              child: Text(
                'Empty task'.tr,
                style: kNormalStyle,
              ),
            ),
          );
        },
      );

  /// [Shared]
  List<Task> taskPrioritySort(List<Task> taskList) {
    List<Task> _newList = [];
    for (int i = 0; i <= 2; i++) {
      for (Task task in taskList) {
        if (task.priority.index == i) {
          _newList.add(task);
        }
      }
    }
    return _newList;
  }

  List<Task> taskFilterProcess(List<Task> taskList) {
    List<Task> _taskList = taskList;

    if (_taskFilterMap['taskFilter'].contains(true)) {
      /// Save position true value in taskFilterMap
      List<int> _filterCategoryPosition = [];
      List<Task> _filterTaskList = [];

      /// Process
      for (int i = 0; i < _taskFilterMap['taskFilter'].length; i++) {
        if (_taskFilterMap['taskFilter'][i]) {
          _filterCategoryPosition.add(i);
        }
      }

      _taskList.forEach((task) {
        bool _isAdd = true;

        for (int i = 0; i < _filterCategoryPosition.length; i++) {
          if (!task.catagories[_filterCategoryPosition[i]]) {
            _isAdd = false;
            break;
          }
        }

        if (_isAdd) _filterTaskList.add(task);
      });

      _taskList = _filterTaskList;
    }

    if (priorityList[_taskFilterMap['priority'].index] != "All") {
      List<Task> _filterTaskList = [];

      _taskList.forEach((task) {
        if (task.priority == _taskFilterMap['priority']) {
          _filterTaskList.add(task);
        }
      });
      _taskList = _filterTaskList;
    }

    return _taskList;
  }

  List<Todo> todoPrioritySort(List<Todo> todoList) {
    List<Todo> _newList = [];
    for (int i = 0; i <= 2; i++) {
      for (Todo todo in todoList) {
        if (todo.priority.index == i) {
          _newList.add(todo);
        }
      }
    }
    return _newList;
  }

  List<Todo> todoFilterProcess(List<Todo> todoList) {
    List<Todo> _todoList = todoList;

    if (_todoFilterMap['todoFilter'].contains(true)) {
      List<int> _filterCategoryPosition = [];

      for (int i = 0; i < _todoFilterMap['todoFilter'].length; i++) {
        if (_todoFilterMap['todoFilter'][i]) {
          _filterCategoryPosition.add(i);
        }
      }

      List<Todo> _filterTodoList = [];
      _todoList.forEach((todo) {
        bool _isAdd = true;

        for (int i = 0; i < _filterCategoryPosition.length; i++) {
          if (!todo.catagories[_filterCategoryPosition[i]]) {
            _isAdd = false;
            break;
          }
        }

        if (_isAdd) _filterTodoList.add(todo);
      });

      _todoList = _filterTodoList;
    }

    if (_todoFilterMap['priority'] != PriorityState.All) {
      List<Todo> _filterTodoList = [];

      _todoList.forEach((todo) {
        if (todo.priority == _todoFilterMap['priority']) {
          _filterTodoList.add(todo);
        }
      });
      _todoList = _filterTodoList;
    }

    return _todoList;
  }

  Color colorStateOfPokemon(int state) {
    if (state == 0) {
      return Colors.black45;
    } else {
      return null;
    }
  }

  BlendMode colorBlendStateOfPokemon(int state) {
    if (state == 0) {
      return BlendMode.modulate;
    } else {
      return null;
    }
  }

  compareTime() async {
    DateTime _earlier;
    if (await readTime() != null)
      _earlier = DateTime.parse(await readTime());
    else {
      await setTime();
      _earlier = DateTime.parse(await readTime());
    }

    DateTime _now = DateTime.now();

    if (_earlier.year < _now.year) {
      await resetVideoReward();
    } else if (_earlier.month < _now.month) {
      await resetVideoReward();
    } else if (_earlier.day < _now.day) {
      await resetVideoReward();
    }

    setTime();
  }

  String getTimeNow() {
    DateTime _now = DateTime.now();

    if (_now.hour <= 12) {
      return 'Good morning,'.tr;
    } else if (_now.hour <= 17) {
      return 'Good afternoon,'.tr;
    } else {
      return 'Good evening,'.tr;
    }
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
}
