import 'package:flutter/material.dart';
import 'package:gottask/utils/utils.dart';

class PetTagCustom extends StatelessWidget {
  final String nameTag;
  final String colorTag;
  final double width;
  final double height;
  final TextStyle style;
  const PetTagCustom({
    this.nameTag,
    this.height,
    this.width,
    this.style,
    @required this.colorTag,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
        bottom: 5,
        right: 10,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Material(
          color: tagColor[colorTag],
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Text(
                nameTag,
                style: style,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
