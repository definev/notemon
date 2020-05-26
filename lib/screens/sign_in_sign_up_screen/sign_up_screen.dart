import 'package:flutter/material.dart';
import 'package:gottask/utils/constant.dart';
import 'package:gottask/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 4,
            decoration: BoxDecoration(
              color: Color(0xFFF9FBFC),
              // gradient: LinearGradient(
              //   colors: [
              //     Color(0xFFFEDCBA),
              //     Colors.white24,
              //   ],
              //   begin: Alignment.centerLeft,
              //   end: Alignment.centerRight,
              // ),
            ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.mail,
                              size: 30,
                              color: Color(0xFF0060F8),
                            ),
                            SizedBox(width: 22),
                            Expanded(
                              child: TextField(
                                cursorColor: TodoColors.deepPurple,
                                style: kMediumStyle,
                                decoration: InputDecoration(
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
                              color: Color(0xFF0060F8),
                            ),
                            SizedBox(width: 22),
                            Expanded(
                              child: TextField(
                                cursorColor: TodoColors.deepPurple,
                                style: kMediumStyle,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: kMediumStyle,
                                  hintText: 'Your password',
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
                              color: Color(0xFF0060F8),
                            ),
                            SizedBox(width: 22),
                            Expanded(
                              child: TextField(
                                cursorColor: TodoColors.deepPurple,
                                style: kMediumStyle,
                                decoration: InputDecoration(
                                  labelText: 'Rewrite password',
                                  labelStyle: kMediumStyle,
                                  hintText: 'Rewrite your password',
                                  hintStyle: kTinySmallStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                                'Sign up and login',
                                style:
                                    kMediumStyle.copyWith(color: Colors.white),
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
