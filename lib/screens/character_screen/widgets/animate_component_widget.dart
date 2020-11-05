import 'dart:typed_data';

import 'package:flutter/material.dart';

class AnimateComponentWidget extends StatefulWidget {
  final double scale;
  final List<Uint8List> listImage;
  AnimateComponentWidget({
    Key key,
    this.listImage,
    this.scale = 1,
  }) : super(key: key);

  @override
  _AnimateComponentWidgetState createState() => _AnimateComponentWidgetState();
}

class _AnimateComponentWidgetState extends State<AnimateComponentWidget> {
  int frame = 2;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: frame),
      duration: Duration(milliseconds: 500),
      onEnd: () {
        if (frame == 2)
          frame = 0;
        else
          frame = 2;
        setState(() {});
      },
      builder: (context, value, child) => Transform.scale(
        scale: widget.scale,
        child: Image.memory(
          widget.listImage[value],
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
