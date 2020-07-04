import 'package:flutter/material.dart';
import 'package:gottask/utils/utils.dart';

class PetTag extends StatelessWidget {
  final String nameTag;
  final TextStyle style;
  const PetTag({
    this.nameTag,
    this.style,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 10,
        bottom: 5,
        top: 5,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Material(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Center(
              child: Text(
                nameTag,
                style: style,
              ),
            ),
          ),
          color: tagColor[nameTag],
          borderRadius: BorderRadius.circular(5),
          elevation: 3,
        ),
      ),
    );
  }
}
