import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gottask/bloc/all_pokemon/bloc/all_pokemon_bloc.dart';
import 'package:gottask/bloc/do_del_done_habit/bloc/do_del_done_habit_bloc.dart';
import 'package:gottask/bloc/do_del_done_todo/bloc/do_del_done_todo_bloc.dart';
import 'package:gottask/bloc/favourite_pokemon/bloc/favourite_pokemon_bloc.dart';
import 'package:gottask/bloc/habit/bloc/habit_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/todo/bloc/todo_bloc.dart';
import 'package:gottask/screens/home_screen.dart';
import 'package:gottask/screens/splash_screen/splash_screen.dart';
import 'package:gottask/utils/utils.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isStart;

  @override
  void initState() {
    super.initState();
    isStart();
  }

  isStart() async {
    _isStart = await currentStartState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: _isStart != null
          ? MultiProvider(
              providers: [
                BlocProvider<TodoBloc>.value(
                  value: TodoBloc(),
                ),
                BlocProvider<HabitBloc>.value(
                  value: HabitBloc(),
                ),
                BlocProvider<DoDelDoneHabitBloc>.value(
                  value: DoDelDoneHabitBloc(),
                ),
                BlocProvider<DoDelDoneTodoBloc>.value(
                  value: DoDelDoneTodoBloc(),
                ),
                BlocProvider<AllPokemonBloc>.value(
                  value: AllPokemonBloc(),
                ),
                BlocProvider<StarBloc>.value(
                  value: StarBloc(),
                ),
                BlocProvider<FavouritePokemonBloc>.value(
                  value: FavouritePokemonBloc(),
                ),
              ],
              child: MaterialApp(
                title: 'Gottash',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  canvasColor: Colors.transparent,
                  scaffoldBackgroundColor: TodoColors.scaffoldWhite,
                  appBarTheme: AppBarTheme(
                    color: TodoColors.deepPurple,
                  ),
                  unselectedWidgetColor: Colors.black,
                  accentColor: TodoColors.deepPurple,
                  primaryColor: TodoColors.deepPurple,
                ),
                initialRoute: _isStart ? '/home' : '/splash',
                routes: {
                  '/splash': (context) => SplashScreen(),
                  '/home': (context) => HomeScreen(),
                },
              ),
            )
          : Container(
              color: TodoColors.deepPurple,
            ),
    );
  }
}
