import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/utils/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SplashScreen extends StatefulWidget {
  final bool isInit;
  SplashScreen({this.isInit});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  PageController controller = PageController(viewportFraction: 0.8);
  bool _done = false;
  int _page = 5;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF6F7F8),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 35,
            ),
            Flexible(
              flex: 5,
              child: PageView.builder(
                physics: BouncingScrollPhysics(),
                controller: controller,
                itemBuilder: (context, pos) {
                  return FittedBox(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            spreadRadius: 0,
                            color: TodoColors.deepPurple.withOpacity(0.5),
                          ),
                        ],
                        color: TodoColors.deepPurple,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          splashScreen[pos],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
                onPageChanged: (value) {
                  setState(() {
                    if (value == _page - 1)
                      _done = true;
                    else
                      _done = false;
                  });
                },
                itemCount: _page,
              ),
            ),
            Flexible(
              flex: 1,
              child: Center(
                child: _done == false
                    ? SmoothPageIndicator(
                        controller: controller,
                        count: _page,
                        effect: WormEffect(
                          activeDotColor: TodoColors.deepPurple,
                        ),
                      )
                    : Material(
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 25,
                          ),
                          decoration: BoxDecoration(
                            color: TodoColors.deepPurple,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: TodoColors.deepPurple.withOpacity(0.5),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () async {
                              if (widget.isInit == null) {
                                await updateStartState();
                                Navigator.popAndPushNamed(context, '/signIn');
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.isInit == null
                                      ? 'Let\'s go!'
                                      : 'Go back',
                                  style: TextStyle(
                                    fontFamily: 'Alata',
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(
                                  AntDesign.arrowright,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
