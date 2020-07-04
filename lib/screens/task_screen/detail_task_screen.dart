import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum DoState {
  ALL,
  DONE,
  ONDOING,
  REMOVE,
}

class DetailTaskScreen extends StatefulWidget {
  @override
  _DetailTaskScreenState createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  String catagory;
  DoState state;
  // TaskBloc _TaskBloc;

  @override
  Widget build(BuildContext context) {
    // _TaskBloc = Provider.of<TaskBloc>(context);
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
      // body: StreamBuilder<List<Task>>(
      //   stream: _TaskBloc.listTaskStream,
      //   builder: (_, snapshot) {
      //     if (snapshot.hasData) {
      //       return Column(
      //         children: List.generate(
      //           _TaskBloc.TaskList.length,
      //           (index) => TaskTile(
      //             Task: _TaskBloc.TaskList[index],
      //           ),
      //         ),
      //       );
      //     }
      //   },
      // ),
    );
  }
}
