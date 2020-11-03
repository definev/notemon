import 'package:flutter/material.dart';
import 'package:gottask/utils/character_helper.dart';
import 'package:gottask/utils/utils.dart';

class CharacterScreen extends StatefulWidget {
  CharacterScreen({Key key}) : super(key: key);

  @override
  _CharacterScreenState createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  CharacterHelper characterHelper;

  @override
  void initState() {
    characterHelper = CharacterHelper(
      ItemArrangerment(
        // beard: CharacterHelper.getImagePath("Beard", "rare", 1),
        body: CharacterHelper.getImagePath("Body", "rare", 3),
        eye: CharacterHelper.getImagePath("Eye", "trivial", 3),
        skin: CharacterHelper.getImagePath("Skin", "rare", 1),
      ),
    );
    characterHelper.init().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: TodoColors.scaffoldWhite,
          child: characterHelper.isInit
              ? Column(
                  children: List.generate(
                    3,
                    (index) => Image.memory(
                      characterHelper.front[index],
                      width: 300,
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : SizedBox(),
        ),
      ),
    );
  }
}
