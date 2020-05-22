import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin BlocCreator<T extends StatefulWidget> on State<T> {
  B findBloc<B>() => Provider.of<B>(context);
}