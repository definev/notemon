import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gottask/models/template_todo.dart';
import 'package:gottask/screens/todo_screen/add_todo_screen.dart';
import 'package:gottask/utils/utils.dart';

class TemplateTodoScreen extends StatefulWidget {
  TemplateTodoScreen({Key key}) : super(key: key);

  @override
  _TemplateTodoScreenState createState() => _TemplateTodoScreenState();
}

class _TemplateTodoScreenState extends State<TemplateTodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TodoColors.scaffoldWhite,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 270,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 0.9],
                  colors: [
                    Color(0xFFFEDCBA),
                    TodoColors.scaffoldWhite,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "Template",
                      style: NotemonTextStyle.kBigTitleStyle.copyWith(
                        fontSize: 60,
                        color: TodoColors.blueMoon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: Get.width - 30,
                      decoration: BoxDecoration(
                        color:
                            Color.alphaBlend(Colors.white, Colors.transparent),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            spreadRadius: 3,
                            color: TodoColors.spaceGrey.withOpacity(0.02),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: SizedBox(
                              child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: "Search your template",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: BouncingScrollPhysics(),
                          children: List.generate(
                              TemplateTodoImpl.values.length, (index) {
                            TemplateTodo templateTodo =
                                TemplateTodoImpl.values[index];
                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => AddTodoScreen(
                                    templateTodo: templateTodo,
                                  ),
                                );
                              },
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(15),
                                child: Center(
                                  child: Text(
                                    "${Get.locale == Locale("en", "") ? templateTodo.name.en : templateTodo.name.vi}",
                                    style: NotemonTextStyle.kMediumStyle
                                        .copyWith(fontSize: 16),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
