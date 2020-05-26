import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gottask/bloc/all_pokemon/bloc/all_pokemon_bloc.dart';
import 'package:gottask/bloc/do_del_done_task/bloc/do_del_done_task_bloc.dart';
import 'package:gottask/bloc/do_del_done_todo/bloc/do_del_done_todo_bloc.dart';
import 'package:gottask/bloc/favourite_pokemon/bloc/favourite_pokemon_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/bloc/todo/bloc/todo_bloc.dart';
import 'package:gottask/screens/home_screen.dart';
import 'package:gottask/screens/sign_in_sign_up_screen/sign_in_screen.dart';
import 'package:gottask/screens/splash_screen/splash_screen.dart';
import 'package:gottask/utils/utils.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isStart;
  bool _isLogin;

  @override
  void initState() {
    super.initState();
    isStart();
  }

  isStart() async {
    _isStart = await currentStartState();
    _isLogin = await currentLoginState();
    setState(() {});
  }

  String getRoute() {
    if (_isLogin == false && _isStart == false) {
      return '/splash';
    } else if (_isLogin == false) {
      return '/signIn';
    } else if (_isStart == true) {
      return '/home';
    }
    return '/splash';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: _isStart != null
          ? MultiProvider(
              providers: [
                BlocProvider<TodoBloc>(
                  create: (context) => TodoBloc(),
                ),
                BlocProvider<TaskBloc>(
                  create: (context) => TaskBloc(),
                ),
                BlocProvider<DoDelDoneTaskBloc>(
                  create: (context) => DoDelDoneTaskBloc(),
                ),
                BlocProvider<DoDelDoneTodoBloc>(
                  create: (context) => DoDelDoneTodoBloc(),
                ),
                BlocProvider<AllPokemonBloc>(
                  create: (context) => AllPokemonBloc(),
                ),
                BlocProvider<StarBloc>(
                  create: (context) => StarBloc(),
                ),
                BlocProvider<FavouritePokemonBloc>(
                  create: (context) => FavouritePokemonBloc(),
                ),
              ],
              child: MaterialApp(
                title: 'Notemon',
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
                initialRoute: getRoute(),
                routes: {
                  '/splash': (context) => SplashScreen(),
                  '/home': (context) => HomeScreen(),
                  '/signIn': (context) => SignInScreen(),
                },
              ),
            )
          : Container(
              color: TodoColors.deepPurple,
            ),
    );
  }
}
