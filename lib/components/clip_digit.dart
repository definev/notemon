import 'package:flutter/cupertino.dart';
import 'package:gottask/components/slide_direction.dart';

class ClipHalfRect extends CustomClipper<Rect> {
  final double percentage;
  final bool isUp;
  final SlideDirection slideDirection;

  ClipHalfRect({
    @required this.percentage,
    @required this.isUp,
    @required this.slideDirection,
  });

  @override
  Rect getClip(Size size) {
    Rect rect;
    if (slideDirection == SlideDirection.Down) {
      if (isUp)
        rect = Rect.fromLTRB(
            0.0, size.height * -percentage, size.width, size.height);
      else
        rect = Rect.fromLTRB(
          0.0,
          0.0,
          size.width,
          size.height * (1 - percentage),
        );
    } else {
      if (isUp)
        rect =
            Rect.fromLTRB(0.0, size.height * (1 + percentage), size.width, 0.0);
      else
        rect = Rect.fromLTRB(
            0.0, size.height * percentage, size.width, size.height);
    }
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
