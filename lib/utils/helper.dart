import 'package:flutter/material.dart';
import 'package:gottask/utils/utils.dart';
import 'package:provider/provider.dart';

mixin BlocCreator<T extends StatefulWidget> on State<T> {
  B findBloc<B>() => Provider.of<B>(context);
}

mixin FilterMixin<T extends StatefulWidget> on State<T> {
  setPriorityColor(String value) {
    if (value == "Low") {
      return TodoColors.lightGreen;
    } else if (value == "Medium") {
      return TodoColors.chocolate;
    } else if (value == "High") {
      return TodoColors.massiveRed;
    } else
      return TodoColors.blueAqua;
  }

  EdgeInsets marginCategory(int index) {
    return EdgeInsets.only(bottom: 10);
  }

  EdgeInsets paddingCategory() {
    return EdgeInsets.symmetric(horizontal: 10);
  }

  double iconSize() => 16;

  double fontSize() => 16;
}
