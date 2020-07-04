import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/screens/splash_screen/splash_screen.dart';
import 'package:gottask/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatefulWidget {
  @override
  _AboutMeScreenState createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  Animation fadeAnimation;

  bool _isCheckGmail = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
    fadeAnimation =
        Tween<double>(begin: 1, end: 0).animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About this app',
          style: kTitleStyle.copyWith(
              fontFamily: 'Montserrat', color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(SimpleLineIcons.question),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreen(
                    isInit: true,
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '''Notemon is my personal project. If you like it, rate it 5 stars ^.^, or if you are not satisfied with this app, please give me a comment. ''',
                        style: TextStyle(
                          fontFamily: 'Source_Sans_Pro',
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Contact me',
                        style: kTitleStyle.copyWith(fontFamily: 'Montserrat'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return GestureDetector(
                                onTap: () {
                                  if (_isCheckGmail == false) {
                                    animationController.forward();
                                    _isCheckGmail = true;
                                  } else {
                                    _isCheckGmail = false;
                                    animationController.reverse();
                                  }
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: 'big.plus.uwu@gmail.com',
                                    ),
                                  );
                                  if (_isCheckGmail == true)
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Copied!',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(200),
                                  elevation: 2,
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(10),
                                    height: 60,
                                    width: animation.value * 170 + 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Stack(
                                        children: <Widget>[
                                          Center(
                                            child: FadeTransition(
                                              opacity: fadeAnimation,
                                              child: Icon(
                                                MaterialCommunityIcons.gmail,
                                                color: Color(0xFFD93025),
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                          if (animation.value == 1)
                                            Center(
                                              child: Text(
                                                'big.plus.uwu@gmail.com',
                                                style: kNormalStyle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () async {
                              const url = 'https://www.facebook.com/definev';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(200),
                              elevation: 2,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: FadeTransition(
                                          opacity: fadeAnimation,
                                          child: Icon(
                                            MaterialCommunityIcons.facebook,
                                            size: 40,
                                            color: Color(0xFF4267B2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              const url = 'https://github.com/definev';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(200),
                              elevation: 2,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
                                height: 60,
                                width: animation.value * 170 + 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: FadeTransition(
                                          opacity: fadeAnimation,
                                          child: Icon(
                                            MaterialCommunityIcons
                                                .github_circle,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Lisence',
                        style: kTitleStyle.copyWith(fontFamily: 'Montserrat'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '''
© 2020 Pokémon. © 1995–2020 Nintendo/Creatures Inc./GAME FREAK inc. Pokémon, Pokémon character names, Nintendo Switch, Nintendo 3DS, Nintendo DS, Wii, Wii U, and WiiWare are trademarks of Nintendo. The YouTube logo is a trademark of Google Inc. Other trademarks are the property of their respective owners.

Distribution in any form and any channels now known or in the future of derivative works based on the copyrighted property trademarks, service marks, trade names and other proprietary property (Fan Art) of The Pokémon Company International, Inc., its affiliates and licensors (Pokémon) constitutes a royalty-free, non-exclusive, irrevocable, transferable, sub-licensable, worldwide license from the Fan Art's creator to Pokémon to use, transmit, copy, modify, and display Fan Art (and its derivatives) for any purpose. No further consideration or compensation of any kind will be given for any Fan Art. Fan Art creator gives up any claims that the use of the Fan Art violates any of their rights, including moral rights, privacy rights, proprietary rights publicity rights, rights to credit for material or ideas or any other right, including the right to approve the way such material is used. In no uncertain terms, does Pokémon's use of Fan Art constitute a grant to Fan Art's creator to use the Pokémon intellectual property or Fan Art beyond a personal, noncommercial home use.''',
                        style: kTinySmallStyle.copyWith(fontSize: 9),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
