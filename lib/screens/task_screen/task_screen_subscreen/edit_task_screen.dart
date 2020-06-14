// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:gottask/utils/utils.dart';

// class EditTaskScreen extends StatefulWidget {
//   @override
//   _EditTaskScreenState createState() => _EditTaskScreenState();
// }

// class _EditTaskScreenState extends State<EditTaskScreen> {
//   Widget _buildTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 3, bottom: 5, top: 2),
//       child: Text(
//         title,
//         style: kNormalStyle.copyWith(color: Colors.grey[600]),
//       ),
//     );
//   }

//   Widget _buildTaskNameTextField() => AnimatedContainer(
//         duration: Duration(milliseconds: 100),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: Color(int.parse(colors[indexColor])),
//             width: 1,
//           ),
//         ),
//         child: TextField(
//           controller: _todoEditting,
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.all(10),
//             labelText: 'To-do name',
//             labelStyle: kNormalStyle.copyWith(color: Colors.grey),
//             focusColor: TodoColors.lightOrange,
//             border: InputBorder.none,
//           ),
//         ),
//       );

//   Widget _buildEditTaskButton(BuildContext context) => GestureDetector(
//         onTap: () async {},
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 300),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Icon(
//                   Ionicons.ios_add,
//                   color: Colors.white,
//                 ),
//                 Text(
//                   ' Edit task',
//                   style: kNormalStyle.copyWith(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//           color: Color(int.parse(colors[indexColor])),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: Theme.of(context)
//           .copyWith(accentColor: Color(int.parse(colors[indexColor]))),
//       child: Scaffold(
//         resizeToAvoidBottomPadding: false,
//         bottomNavigationBar: _buildEditTaskButton(context),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   _buildTaskNameTextField(),
//                   _buildTitle('Color'),
//                   _buildColorPicker(),
//                   _buildTitle('Priority'),
//                   _buildPriorityPicker(),
//                   _buildTitle('Catagory'),
//                   _buildCatagoriesPicker(context),
//                   _buildTitle('File'),
//                   _buildFilePicker(context),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
