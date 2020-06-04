import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ParrallelBackground extends StatefulWidget {
  final Widget child;

  const ParrallelBackground({Key key, this.child}) : super(key: key);
  @override
  _ParrallelBackgroundState createState() => _ParrallelBackgroundState();
}

class _ParrallelBackgroundState extends State<ParrallelBackground> {
  Ticker _ticker;
  @override
  void initState() {
    _ticker = Ticker((d) {
      setState(() {});
    })
      ..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var time = DateTime.now().millisecondsSinceEpoch / 2000;
    var scaleX = 1.2 + sin(time) * .08;
    var scaleY = 1.2 + cos(time) * .06;
    return Transform.translate(
      offset: Offset(-(scaleX - 1) / 3 * size.width + size.width / 10,
          -(scaleY - 1.2) / 3 * size.height),
      child: widget.child,
    );
  }
}
