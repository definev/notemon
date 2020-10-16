import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/constant.dart';
import 'package:gottask/utils/utils.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reWritePasswordController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _reWritePasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  FirebaseRepository _repository;

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
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.only(left: 50),
                              child: Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 200,
                                  child: Text(
                                    'Notemon',
                                    textAlign: TextAlign.center,
                                    style: kBigTitleStyle.copyWith(
                                      fontFamily: "Tomorrow",
                                      color: Colors.white,
                                    ),
                                  ),
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
                    height: MediaQuery.of(context).size.height / 2,
                    child: Form(
                      key: _formKey,
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
                                  validator: (value) {
                                    bool valid = RegexValidation.hasMatch(
                                        value, RegexPattern.email);

                                    if (!valid) return "Email format wrong.";

                                    return null;
                                  },
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
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
                                    hintText: 'Your email'.tr,
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
                                  validator: (value) {
                                    bool valid = RegexValidation.hasMatch(
                                        value, RegexPattern.passwordNormal3);

                                    if (!valid)
                                      return "Password must contain at least one number and one uppercase letter.";

                                    return null;
                                  },
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  onFieldSubmitted: (_) =>
                                      _reWritePasswordFocusNode.requestFocus(),
                                  obscureText: true,
                                  cursorColor: TodoColors.deepPurple,
                                  style: kMediumStyle,
                                  decoration: InputDecoration(
                                    errorStyle: kTinySmallStyle.copyWith(
                                      color: Colors.red,
                                      fontSize: 10,
                                    ),
                                    labelText: 'Password'.tr,
                                    labelStyle: kMediumStyle,
                                    hintText: 'Your password'.tr,
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
                                  validator: (value) {
                                    if (_passwordController.text != value ||
                                        value == "") {
                                      return "Not match with password.";
                                    }
                                    return null;
                                  },
                                  controller: _reWritePasswordController,
                                  focusNode: _reWritePasswordFocusNode,
                                  onFieldSubmitted: (_) async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() => _isLoading = true);
                                      if (await checkConnection()) {
                                        FirebaseUser user = await AuthServices()
                                            .handleSignUpEmail(
                                          _emailController.text,
                                          _passwordController.text,
                                        );

                                        if (user == null) {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Failed to sign in'.tr),
                                            ),
                                          );
                                        } else {
                                          await _loginSuccess();
                                        }
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'No internet connection.'.tr),
                                          ),
                                        );
                                      }
                                      setState(() => _isLoading = false);
                                    } else {
                                      _emailController.clear();
                                      _passwordController.clear();
                                      _reWritePasswordController.clear();
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
                                    labelText: 'Rewrite password'.tr,
                                    labelStyle: kMediumStyle,
                                    hintText: 'Rewrite your password'.tr,
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
                  SizedBox(
                    height: 80,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: 80,
                            child: CustomPaint(painter: ButtonPainter(context)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => _isLoading = true);
                              if (await checkConnection()) {
                                FirebaseUser user =
                                    await AuthServices().handleSignUpEmail(
                                  _emailController.text,
                                  _passwordController.text,
                                );

                                if (user == null) {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to sign up and sign in.'),
                                    ),
                                  );
                                } else {
                                  await _loginSuccess();
                                }
                              } else {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No internet connection.'.tr),
                                  ),
                                );
                              }
                              setState(() => _isLoading = false);
                            } else {
                              _emailController.clear();
                              _passwordController.clear();
                              _reWritePasswordController.clear();
                            }
                          },
                          child: Center(
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
                                  'Sign up and login'.tr,
                                  style: kMediumStyle.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
