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
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/components/habit_tile.dart';
import 'package:gottask/components/todo_tile.dart';
import 'package:gottask/helper.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/pokemon_screen/all_pokemon_screen.dart';
import 'package:gottask/screens/task_screen/task_export.dart';
import 'package:gottask/screens/todo_screen/add_todo_screen.dart';
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
  Map<String, bool> _isLoading = {
    'todo': false,
    'task': false,
    'pokemonState': false,
  };

  ConnectionStatusSingleton connectionStatus;
  StreamController<bool> _connectionChangeStream;

  TodoBloc _todoBloc;
  TaskBloc _taskBloc;
  AllPokemonBloc _allPokemonBloc;
  StarBloc _starBloc;
  FavouritePokemonBloc _favouritePokemonBloc;

  FirebaseRepository _repository;

  void _modalBottomSheetMenu() {
    showModalBottomSheet(context: context, builder: (_) => AddTodoScreen());
  }

  _updateDatabase() async {
    if (_repository.user == null) await _repository.initUser();
    if (_todoBloc.todoList != null) {
      List<String> _deleteKey = _todoBloc.deleteTodoKey;
      List<String> _deleteKeyInServer = await _repository.getDeleteTodoKey();
      List<String> _finalDeleteKey = [..._deleteKey, ..._deleteKeyInServer];
      _finalDeleteKey = LinkedHashSet<String>.from(_finalDeleteKey).toList();
      _repository.setDeleteTodoKey(_finalDeleteKey);
      List<Todo> _todoListServer = [];

      await _repository.getAllTodo().then(
        (todoListServerRaw) {
          _todoListServer = todoListServerRaw;
          List<Todo>.from(todoListServerRaw).forEach((todo) {
            if (_finalDeleteKey.contains(todo.id)) {
              _todoListServer.remove(todo);
              _repository.deleteTodoOnFirebase(todo);
            }
          });
        },
      );

      List<Todo> _todoListLocal = _todoBloc.todoList;
      List<Todo>.from(_todoBloc.todoList).forEach((todo) {
        if (_finalDeleteKey.contains(todo.id)) {
          _todoListLocal.remove(todo);
          _todoBloc.add(DeleteTodoEvent(todo: todo));
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

      await _repository.uploadAllTodoToFirebase(_todoListFinal);
      _todoListAddIn.forEach(
        (todo) => _todoBloc.add(AddTodoEvent(todo: todo)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: appId);
    setLoadAdsInfirst(false);
    connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream = connectionStatus.connectionChangeController;
    _connectionChangeStream.stream.listen(
      (hasInternet) async {
        if (hasInternet) {
          setState(() => _isLoading['todo'] = true);
          await _updateDatabase();
          setState(() => _isLoading['todo'] = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _connectionChangeStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) {
      _todoBloc = findBloc<TodoBloc>();
      _taskBloc = findBloc<TaskBloc>();
      _allPokemonBloc = findBloc<AllPokemonBloc>();
      _starBloc = findBloc<StarBloc>();
      _repository = findBloc<FirebaseRepository>();
      _repository.initUser().then((_) => setState(() {}));
      _favouritePokemonBloc = findBloc<FavouritePokemonBloc>();
      _todoBloc.add(InitTodoEvent());
      _taskBloc.add(InitTaskEvent());
      _allPokemonBloc.add(InitAllPokemonEvent());
      _starBloc.add(InitStarBloc());
      _favouritePokemonBloc.add(InitFavouritePokemonEvent());
      _isInit = true;
    }
    if (_repository.user == null) {
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
            stream: _connectionChangeStream.stream,
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
              print(snapshot.data);
              return IndexedStack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildOfflineHeader(),
                      _buildOfflinePetCollection(),
                      _buildOfflineTaskTitle(),
                      _buildOfflineTask(),
                      _buildOfflineTodoHeader(),
                      _buildOfflineTodo(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildOnlineHeader(),
                      _buildOnlinePetCollection(),
                      _buildOnlineTaskTitle(),
                      _buildOnlineTask(),
                      _buildOnlineTodoHeader(),
                      _buildOnlineTodo(),
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

  Widget _buildOnlineHeader() {
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
                      stream: _repository.favouritePokemonStream(),
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

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BlocProvider<HandSideBloc>.value(
                                    value: HandSideBloc(),
                                    child: AllPokemonScreen(currentPokemon: 0),
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
                          _repository.updateFavouritePokemon(-1);
                          return Container();
                        }

                        FavouritePokemon _favouritePokemon =
                            FavouritePokemon.fromMap(
                                snapshot.data.documents[0].data);

                        if (_favouritePokemon.pokemon != -1) {
                          return GestureDetector(
                            onTap: () async {
                              await compareTime();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BlocProvider<HandSideBloc>.value(
                                    value: HandSideBloc(),
                                    child: AllPokemonScreen(
                                      currentPokemon: _favouritePokemon.pokemon,
                                    ),
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
                                  pokedex[_favouritePokemon.pokemon]
                                      ["imageURL"],
                                  height: 30,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              await compareTime();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BlocProvider<HandSideBloc>.value(
                                    value: HandSideBloc(),
                                    child: AllPokemonScreen(currentPokemon: 0),
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
                                stream: _repository.starpointStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Text(
                                      '0 ',
                                      style: kNormalStyle,
                                    );
                                  }
                                  if (snapshot.data.data == null) {
                                    _repository.updateStarpoint(0);
                                    return Text(
                                      '0 ',
                                      style: kNormalStyle,
                                    );
                                  }
                                  Starpoint _starPoint =
                                      Starpoint.fromMap(snapshot.data.data);

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
  }

  Widget _buildOnlinePetCollection() {
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
            stream: _repository.pokemonStateStream(),
            builder: (context, snapshot) {
              if (snapshot.data == null ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text('Waiting ...'),
                );
              }
              if (snapshot.data.documents.isEmpty) {
                List<PokemonState> _pokemonStates = [];
                pokedex.forEach((poke) {
                  _pokemonStates.add(
                    PokemonState(
                      name: poke['name'],
                      state: 0,
                    ),
                  );
                });
                _repository.uploadAllPokemonStateToFirebase(_pokemonStates);
                return Center(
                  child: Text('Waiting ...'),
                );
              }
              List<PokemonState> _pokemonStateList = [];
              snapshot.data.documents.forEach((map) =>
                  _pokemonStateList.add(PokemonState.fromMap(map.data)));

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                addRepaintBoundaries: true,
                scrollDirection: Axis.horizontal,
                itemCount: _pokemonStateList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await compareTime();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider<HandSideBloc>.value(
                            value: HandSideBloc(),
                            child: AllPokemonScreen(
                              currentPokemon: index,
                            ),
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
                              right: 3,
                              bottom: 3,
                              top: 3,
                            ),
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Image.asset(
                                pokedex[index]["imageURL"],
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
          left: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'To-do list',
              style: kTitleStyle,
            ),
            Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.only(right: 20),
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
        ),
      );

  Widget _buildOnlineTodo() => Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _repository.todoStream(),
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
              snapshots.data.documents
                  .forEach((todo) => _todoList.add(Todo.fromMap(todo.data)));
              if (_todoList.isEmpty) {
                return const Center(
                  child: Text(
                    'Empty to-do',
                    style: kNormalStyle,
                  ),
                );
              } else {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) => TodoTile(
                    task: _todoList[index],
                    key: UniqueKey(),
                  ),
                );
              }
            }

            return const Center(
              child: Text(
                'Empty to-do',
                style: kNormalStyle,
              ),
            );
          },
        ),
      );

  Widget _buildOnlineTaskTitle() => Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Task list',
              style: kTitleStyle,
            ),
            const SizedBox(width: 10),
            Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.only(right: 20),
              child: RawMaterialButton(
                fillColor: TodoColors.deepPurple,
                shape: const CircleBorder(),
                elevation: 0.5,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildOnlineTask() {
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.taskStream(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
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
          _repository.uploadAllTaskToFirebase(_taskBloc.taskList);
          return SizedBox(
            height: kListViewHeight + 2,
            width: double.infinity,
            child: const Center(
              child: Text(
                'Empty task',
                style: kNormalStyle,
              ),
            ),
          );
        } else {
          if (snapshots.data.documents.isEmpty) {
            return SizedBox(
              height: kListViewHeight + 2,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Empty task',
                  style: kNormalStyle,
                ),
              ),
            );
          } else {
            List<Task> _taskList = [];
            snapshots.data.documents
                .forEach((maps) => _taskList.add(Task.fromMap(maps.data)));
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(),
                              ),
                            );
                          },
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

                    return Center(
                      child: TaskTile(
                        task: _taskList[index],
                        key: UniqueKey(),
                      ),
                    );
                  },
                ),
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
                            if (state.pokemon != -1) {
                              return GestureDetector(
                                onTap: () async {
                                  await compareTime();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BlocProvider<HandSideBloc>.value(
                                        value: HandSideBloc(),
                                        child: AllPokemonScreen(
                                          currentPokemon: state.pokemon,
                                        ),
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
                                      pokedex[state.pokemon]["imageURL"],
                                      height: 30,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () async {
                                  await compareTime();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BlocProvider<HandSideBloc>.value(
                                        value: HandSideBloc(),
                                        child:
                                            AllPokemonScreen(currentPokemon: 0),
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
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    addRepaintBoundaries: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.pokemonStateList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          await compareTime();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider<HandSideBloc>.value(
                                value: HandSideBloc(),
                                child: AllPokemonScreen(
                                  currentPokemon: index,
                                ),
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
                                  right: 3,
                                  bottom: 3,
                                  top: 3,
                                ),
                          padding: const EdgeInsets.all(5),
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Image.asset(
                                    pokedex[index]["imageURL"],
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
                  child: Text('Waiting ...'),
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
          left: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'To-do list',
              style: kTitleStyle,
            ),
            Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.only(right: 20),
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
        ),
      );

  Widget _buildOfflineTodo() => Expanded(
        child: BlocBuilder<TodoBloc, TodoState>(
          bloc: _todoBloc,
          builder: (context, state) {
            if (state is TodoLoaded) {
              if (state.todo.isEmpty) {
                return const Center(
                  child: Text(
                    'Empty to-do',
                    style: kNormalStyle,
                  ),
                );
              } else {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: state.todo.length,
                  itemBuilder: (context, index) => TodoTile(
                    task: state.todo[index],
                    key: UniqueKey(),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                'Empty to-do',
                style: kNormalStyle,
              ),
            );
          },
        ),
      );

  Widget _buildOfflineTaskTitle() => Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Task list',
              style: kTitleStyle,
            ),
            const SizedBox(width: 10),
            Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.only(right: 20),
              child: RawMaterialButton(
                fillColor: TodoColors.deepPurple,
                shape: const CircleBorder(),
                elevation: 0.5,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildOfflineTask() {
    return BlocBuilder<TaskBloc, TaskState>(
      bloc: _taskBloc,
      builder: (context, state) {
        if (state is TaskLoaded) {
          if (state.task.isEmpty) {
            return SizedBox(
              height: kListViewHeight + 2,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Empty task',
                  style: kNormalStyle,
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                height: kListViewHeight + 2,
                width: double.infinity,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: state.task.length + 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == state.task.length) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(),
                              ),
                            );
                          },
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

                    return Center(
                      child: TaskTile(
                        task: state.task[index],
                        key: UniqueKey(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        }
        return SizedBox(
          height: kListViewHeight + 2,
          width: double.infinity,
          child: const Center(
            child: Text(
              'Empty task',
              style: kNormalStyle,
            ),
          ),
        );
      },
    );
  }

  /// [Shared]

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
      return 'Good morning,';
    } else if (_now.hour <= 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }
}

//                  Container(
//                   width: 25,
//                   height: 25,
//                   margin: const EdgeInsets.only(right: 10),
//                   child: RawMaterialButton(
//                     fillColor: TodoColors.spaceGrey,
//                     shape: const CircleBorder(),
//                     elevation: 0.5,
//                     child: Icon(
//                       Icons.more_horiz,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DetailTaskScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
