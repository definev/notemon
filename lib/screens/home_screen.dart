import 'dart:ui';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gottask/bloc/all_pokemon/bloc/all_pokemon_bloc.dart';
import 'package:gottask/bloc/do_del_done_habit/bloc/do_del_done_habit_bloc.dart';
import 'package:gottask/bloc/do_del_done_todo/bloc/do_del_done_todo_bloc.dart';
import 'package:gottask/bloc/favourite_pokemon/bloc/favourite_pokemon_bloc.dart';
import 'package:gottask/bloc/habit/bloc/habit_bloc.dart';
import 'package:gottask/bloc/hand_side/bloc/hand_side_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/todo/bloc/todo_bloc.dart';
import 'package:gottask/components/habit_tile.dart';
import 'package:gottask/components/today_task_tile.dart';
import 'package:gottask/helper.dart';
import 'package:gottask/screens/habit_screen/habit_export.dart';
import 'package:gottask/screens/pokemon_screen/all_pokemon_screen.dart';
import 'package:gottask/screens/todo_screen/add_today_task_screen.dart';
import 'package:gottask/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, BlocCreator {
  bool _isInit = false;

  TodoBloc _todoBloc;
  HabitBloc _habitBloc;
  DoDelDoneHabitBloc _doDelDoneHabitBloc;
  DoDelDoneTodoBloc _doDelDoneTodoBloc;
  AllPokemonBloc _allPokemonBloc;
  StarBloc _starBloc;
  FavouritePokemonBloc _favouritePokemonBloc;

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context, builder: (_) => AddTodayTaskScreen());
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: appId);
    setLoadAdsInfirst(false);
  }

  @override
  Widget build(BuildContext context) {
    _todoBloc = findBloc<TodoBloc>();
    _habitBloc = findBloc<HabitBloc>();
    _doDelDoneHabitBloc = findBloc<DoDelDoneHabitBloc>();
    _doDelDoneTodoBloc = findBloc<DoDelDoneTodoBloc>();
    _allPokemonBloc = findBloc<AllPokemonBloc>();
    _starBloc = findBloc<StarBloc>();
    _favouritePokemonBloc = findBloc<FavouritePokemonBloc>();

    if (_isInit == false) {
      _todoBloc.add(InitTodoEvent());
      _habitBloc.add(InitHabitEvent());
      _doDelDoneHabitBloc.add(InitDoDelDoneHabitEvent());
      _doDelDoneTodoBloc.add(InitDoDelDoneTodoEvent());
      _allPokemonBloc.add(InitAllPokemonEvent());
      _starBloc.add(InitStarBloc());
      _favouritePokemonBloc.add(InitFavouritePokemonEvent());
      _isInit = true;
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(),
                  _buildPetCollection(),
                  _buildHabitTitle(),
                  _buildHabit(),
                  _buildTodaysTaskHeader(),
                ],
              ),
              _buildTodayTask(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabit() {
    return BlocBuilder<HabitBloc, HabitState>(
      bloc: _habitBloc,
      builder: (context, state) {
        if (state is HabitLoaded) {
          if (state.habit.isEmpty) {
            return SizedBox(
              height: kListViewHeight + 2,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Empty task',
                  style: TextStyle(fontFamily: 'Alata', fontSize: 16),
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
                  itemCount: state.habit.length + 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == state.habit.length) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddHabitScreen(),
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
                      child: HabitTile(
                        habit: state.habit[index],
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
              style: TextStyle(fontFamily: 'Alata', fontSize: 16),
            ),
          ),
        );
      },
    );
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

  Widget _buildHeader() => Padding(
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
                                      pokemonImages[state.pokemon],
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
                                      return Text(
                                        '${state.currentStar} ',
                                        style: TextStyle(
                                          fontFamily: 'Alata',
                                          fontSize: 16,
                                        ),
                                      );
                                    }
                                    return Text(
                                      '0 ',
                                      style: TextStyle(
                                        fontFamily: 'Alata',
                                        fontSize: 16,
                                      ),
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
                      style: TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF061058),
                      ),
                    ),
                    Text(
                      '${DateFormat.yMMMEd().format(DateTime.now())}',
                      style: TextStyle(
                        fontFamily: 'Alata',
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

  Widget _buildPetCollection() => Padding(
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
          child: Consumer<AllPokemonBloc>(
            builder: (context, bloc, child) => Container(
              height: 85,
              width: MediaQuery.of(context).size.width - 20,
              padding: const EdgeInsets.all(5),
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
                            width: 56,
                            height: 70,
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
                            margin: index < pokemonImages.length - 1
                                ? const EdgeInsets.only(
                                    right: 8,
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
                                  Image.asset(
                                    pokemonImages[index],
                                    height: 70,
                                    width: 70,
                                    color: colorStateOfPokemon(
                                      state.pokemonStateList[index].state,
                                    ),
                                    colorBlendMode: colorBlendStateOfPokemon(
                                      state.pokemonStateList[index].state,
                                    ),
                                  ),
                                  if (state.pokemonStateList[index].state == 0)
                                    Align(
                                      alignment: FractionalOffset.center,
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
        ),
      );

  Padding _buildTodaysTaskHeader() => Padding(
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
              style: TextStyle(fontFamily: 'Alata', fontSize: 20),
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

  Widget _buildTodayTask() => Expanded(
        child: BlocBuilder<TodoBloc, TodoState>(
          bloc: _todoBloc,
          builder: (context, state) {
            if (state is TodoLoaded) {
              if (state.todo.isEmpty) {
                return const Center(
                  child: Text(
                    'Empty to-do',
                    style: TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: state.todo.length,
                  itemBuilder: (context, index) => TodayTaskTile(
                    task: state.todo[index],
                    index: index,
                    key: UniqueKey(),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                'Empty to-do',
                style: TextStyle(
                  fontFamily: 'Alata',
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      );

  Widget _buildHabitTitle() => Padding(
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
              style: TextStyle(fontFamily: 'Alata', fontSize: 20),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(right: 10),
                  child: RawMaterialButton(
                    fillColor: TodoColors.spaceGrey,
                    shape: const CircleBorder(),
                    elevation: 0.5,
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailHabitScreen(),
                        ),
                      );
                    },
                  ),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddHabitScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );

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
