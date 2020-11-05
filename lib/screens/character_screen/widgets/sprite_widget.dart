import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gottask/models/sprite.dart';
import 'package:gottask/utils/character_helper.dart';
import 'package:gottask/utils/utils.dart';

class SpriteWidget extends StatefulWidget {
  final Sprite sprite;
  final double scale;
  final AnimationState animationState;
  final String name;
  final double fontSize;
  final Function(AnimationState) onChangeAnimationState;

  SpriteWidget({
    Key key,
    this.scale,
    this.animationState = AnimationState.front,
    this.name,
    this.fontSize = 17,
    this.sprite,
    this.onChangeAnimationState,
  })  : assert(sprite != null, scale >= 1),
        super(key: key);

  @override
  _SpriteWidgetState createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  SpriteHelper characterHelper;
  AnimationState animationState;

  double scale = 1;
  int frame = 2;

  String name;

  @override
  void initState() {
    name = widget.name;
    characterHelper = SpriteHelper(component: widget.sprite.component);
    characterHelper.init().then((_) {
      characterHelper.back
          .forEach((image) => precacheImage(MemoryImage(image), context));
      characterHelper.front
          .forEach((image) => precacheImage(MemoryImage(image), context));
      characterHelper.left
          .forEach((image) => precacheImage(MemoryImage(image), context));
      characterHelper.right
          .forEach((image) => precacheImage(MemoryImage(image), context));
      setState(() {});
    });
    scale = widget.scale;
    animationState = widget.animationState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32 * scale + widget.fontSize * 2,
      height: 32 * scale + widget.fontSize,
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: frame),
        duration: Duration(milliseconds: 500),
        onEnd: () {
          if (frame == 2)
            frame = 0;
          else
            frame = 2;
          setState(() {});
        },
        builder: (context, value, child) => Stack(
          fit: StackFit.loose,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 32 * scale,
                width: 32 * scale,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        int index = AnimationState.values
                            .toList()
                            .indexOf(animationState);

                        animationState = AnimationState.values[(index + 1) % 4];
                        widget.onChangeAnimationState(animationState);
                      });
                    },
                    child: Container(
                      height: 32 * scale,
                      width: 32 * scale,
                      child: characterHelper.isInit
                          ? Transform.scale(
                              scale: scale,
                              child: Image.memory(
                                _getImageFrom(value),
                                filterQuality: FilterQuality.high,
                              ),
                            )
                          : SizedBox(
                              height: 32 * scale,
                              width: 32 * scale,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            if (name != null)
              Positioned(
                top: 3.0 * value,
                child: LimitedBox(
                  maxWidth: 32 * scale + widget.fontSize * 2,
                  child: Center(
                    child: Text(
                      name.removeDiacritics(),
                      style: NotemonTextStyle.kRetroStyle
                          .copyWith(fontSize: widget.fontSize),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Uint8List _getImageFrom(int value) {
    switch (animationState) {
      case AnimationState.back:
        return characterHelper.back[value];
      case AnimationState.front:
        return characterHelper.front[value];
      case AnimationState.left:
        return characterHelper.left[value];
      case AnimationState.right:
        return characterHelper.right[value];
      default:
        return characterHelper.front[value];
    }
  }
}
