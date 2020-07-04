import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/screens/sign_in_sign_up_screen/sign_up_screen.dart';
import 'package:gottask/utils/constant.dart';
import 'package:gottask/utils/utils.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/regexpattern.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthServices _authServices = AuthServices();
  FirebaseRepository _repository;
  bool _isLoading = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  _loginSuccess() async {
    updateLoginState(true);
    await _repository.initUser().then((_) async {
      await _repository.getAllTodoAndLoadToDb(
        Provider.of<TodoBloc>(context, listen: false),
      );
      await _repository.getAllTaskAndLoadToDb(
        Provider.of<TaskBloc>(context, listen: false),
      );
      await _repository.getAllPokemonStateAndLoadToDb(
        Provider.of<AllPokemonBloc>(context, listen: false),
      );
      await _repository.getFavouritePokemonStateAndLoadToDb(
        Provider.of<FavouritePokemonBloc>(context, listen: false),
      );
      await _repository.getStarpoint(
        Provider.of<StarBloc>(context, listen: false),
      );
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.popAndPushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    _repository = Provider.of<FirebaseRepository>(context);
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
                                  text: [
                                    "Notemon",
                                    "Easy to use.",
                                    "Help you focus.",
                                    "Notemon",
                                  ],
                                  textStyle: kBigTitleStyle.copyWith(
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
                  Form(
                    key: _formKey,
                    child: SizedBox(
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
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  validator: (value) {
                                    bool valid = RegexValidation.hasMatch(
                                        value, RegexPattern.email);

                                    if (!valid) return "Email format wrong.";

                                    return null;
                                  },
                                  onFieldSubmitted: (_) =>
                                      _passwordFocusNode.requestFocus(),
                                  cursorColor: TodoColors.deepPurple,
                                  style: kMediumStyle,
                                  decoration: InputDecoration(
                                    errorStyle: kTinySmallStyle.copyWith(
                                      color: Colors.red,
                                      fontSize: 10,
                                    ),
                                    labelText: 'Email',
                                    labelStyle: kMediumStyle,
                                    hintText: 'Your email',
                                    hintStyle: kTinySmallStyle,
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
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  validator: (value) {
                                    bool valid = RegexValidation.hasMatch(
                                        value, RegexPattern.passwordNormal3);

                                    if (!valid)
                                      return "Password must contain at least one number and one uppercase letter.";

                                    return null;
                                  },
                                  onFieldSubmitted: (_) async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() => _isLoading = true);
                                      if (await checkConnection()) {
                                        FirebaseUser user = await _authServices
                                            .handleSignInEmail(
                                          _emailController.text,
                                          _passwordController.text,
                                        );

                                        if (user == null) {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Failed to sign in'),
                                            ),
                                          );
                                        } else {
                                          await _loginSuccess();
                                        }
                                      }
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                  obscureText: true,
                                  cursorColor: TodoColors.deepPurple,
                                  style: kMediumStyle,
                                  decoration: InputDecoration(
                                    errorStyle: kTinySmallStyle.copyWith(
                                      color: Colors.red,
                                      fontSize: 10,
                                    ),
                                    labelText: 'Password',
                                    labelStyle: kMediumStyle,
                                    hintText: 'Your password',
                                    hintStyle: kTinySmallStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => _isLoading = true);
                            if (await checkConnection()) {
                              FirebaseUser user =
                                  await _authServices.handleSignInEmail(
                                _emailController.text,
                                _passwordController.text,
                              );

                              if (user == null) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to sign in'),
                                  ),
                                );
                                _emailController.clear();
                                _passwordController.clear();
                              } else {
                                await _loginSuccess();
                              }
                            }
                            setState(() => _isLoading = false);
                          } else {
                            _emailController.clear();
                            _passwordController.clear();
                          }
                        },
                        child: SizedBox(
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
                                      style: kMediumStyle.copyWith(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          Builder(
                            builder: (context) => InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () async {
                                setState(() => _isLoading = true);
                                if (await checkConnection()) {
                                  FirebaseUser user =
                                      await _authServices.googleSignIn(context);

                                  if (user == null) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to sign in'),
                                      ),
                                    );
                                    _emailController.clear();
                                    _passwordController.clear();
                                  } else {
                                    await _loginSuccess();
                                  }
                                } else {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No internet connection.'),
                                    ),
                                  );
                                }
                                setState(() => _isLoading = false);
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
                          ),
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
                          style: kTitleStyle.copyWith(
                            color: TodoColors.spaceGrey,
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
          if (_isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black45,
              child: LoadingFadingLine.circle(
                backgroundColor: Colors.white,
                size: 100,
              ),
            ),
        ],
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
