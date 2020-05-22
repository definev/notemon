import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum DoState {
  ALL,
  DONE,
  ONDOING,
  REMOVE,
}

class DetailHabitScreen extends StatefulWidget {
  @override
  _DetailHabitScreenState createState() => _DetailHabitScreenState();
}

class _DetailHabitScreenState extends State<DetailHabitScreen> {
  String catagory;
  DoState state;
  // HabitBloc _habitBloc;

  @override
  Widget build(BuildContext context) {
    // _habitBloc = Provider.of<HabitBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All task',
          style: TextStyle(
            fontFamily: 'Alata',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              AntDesign.barschart,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      // body: StreamBuilder<List<Habit>>(
      //   stream: _habitBloc.listHabitStream,
      //   builder: (_, snapshot) {
      //     if (snapshot.hasData) {
      //       return Column(
      //         children: List.generate(
      //           _habitBloc.habitList.length,
      //           (index) => HabitTile(
      //             habit: _habitBloc.habitList[index],
      //           ),
      //         ),
      //       );
      //     }
      //   },
      // ),
    );
  }
}
