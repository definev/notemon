import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gottask/bloc/all_pokemon/bloc/all_pokemon_bloc.dart';
import 'package:gottask/bloc/favourite_pokemon/bloc/favourite_pokemon_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/sign_in_sign_up_screen/sign_up_screen.dart';
import 'package:gottask/utils/constant.dart';
import 'package:gottask/utils/utils.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthServices _authServices = AuthServices();
  FirebaseRepository _repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 4,
            color: Color(0xFFF9FBFC),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: SizedBox(
                      height: 100,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 65,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Color(0xFF485563),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    topLeft: Radius.circular(30),
                                  )),
                              padding: const EdgeInsets.only(left: 50),
                              margin: const EdgeInsets.only(left: 10),
                              child: Center(
                                child: TypewriterAnimatedTextKit(
                                  onTap: () {
                                    print("Tap Event");
                                  },
                                  text: [
                                    "Notemon",
                                    "Easy to use.",
                                    "Help you focus.",
                                    "Notemon",
                                  ],
                                  textStyle: TextStyle(
                                    fontSize: 25,
                                    fontFamily: "Tomorrow",
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  alignment: Alignment.center,
                                  speed: Duration(milliseconds: 250),
                                  totalRepeatCount: 1,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/icon/background.png',
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'assets/icon/icon.png',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.mail,
                              size: 30,
                              color: TodoColors.lightGreen,
                            ),
                            SizedBox(width: 22),
                            Expanded(
                              child: TextField(
                                cursorColor: TodoColors.deepPurple,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Alata',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Alata',
                                  ),
                                  hintText: 'Your email',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Alata',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.lock,
                              size: 30,
                              color: TodoColors.lightGreen,
                            ),
                            SizedBox(width: 22),
                            Expanded(
                              child: TextField(
                                cursorColor: TodoColors.deepPurple,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Alata',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Alata',
                                  ),
                                  hintText: 'Your password',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Alata',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                height: 80,
                                child: CustomPaint(
                                    painter: ButtonPainter(context)),
                              ),
                            ),
                            Center(
                              child: Container(
                                height: 80 - 12 * 1.9,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Color(0xFF485563),
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'Alata',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Or sign in with',
                            style: TextStyle(
                              fontFamily: 'Alata',
                              color: Colors.black54,
                            ),
                          ),
                          _googleSignIn(),
                        ],
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign up new account',
                          style: TextStyle(
                            fontFamily: 'Alata',
                            color: TodoColors.spaceGrey,
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Builder _googleSignIn() {
    return Builder(
      builder: (context) => InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () async {
          if (await checkConnection()) {
            await _authServices.googleSignIn().then(
              (firebaseUser) async {
                if (firebaseUser == null) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign in'),
                    ),
                  );
                } else {
                  await updateLoginState(true);
                  await _repository.initUser();
                  await _repository.getAllTaskAndLoadToDb(
                    Provider.of<TaskBloc>(context),
                  );
                  await _repository.getAllPokemonStateAndLoadToDb(
                    Provider.of<AllPokemonBloc>(context),
                  );
                  await _repository.getFavouritePokemonStateAndLoadToDb(
                    Provider.of<FavouritePokemonBloc>(context),
                  );
                  await _repository.getStarpoint(
                    Provider.of<StarBloc>(context),
                  );
                  Navigator.pushNamed(context, '/home');
                }
              },
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: -8.5,
                color: TodoColors.spaceGrey,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Image.asset(
              'assets/icon/google.jpg',
              height: 55,
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonPainter extends CustomPainter {
  final BuildContext context;

  ButtonPainter(this.context);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();
    double height = 12;
    double realWidth = MediaQuery.of(context).size.width / 2.28 + size.width;

    path.moveTo(realWidth, height);
    path.lineTo(realWidth, 0);
    path.quadraticBezierTo(
      realWidth - height / 2 + height / 4,
      height / 2 + height / 4,
      realWidth - height,
      height,
    );
    path.moveTo(realWidth, size.height);
    path.lineTo(realWidth, size.height - height);
    path.lineTo(realWidth - height, size.height - height);
    path.quadraticBezierTo(
      realWidth - height / 2 + height / 4,
      size.height - (height / 2 + height / 4),
      realWidth,
      size.height,
    );
    path.close();
    paint..color = Color(0xFF485563);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
