import 'package:flutter/material.dart';
import 'package:gottask/screens/character_screen/widgets/animate_component_widget.dart';
import 'package:gottask/utils/character_helper.dart';

class ComponentWidget extends StatefulWidget {
  final List<String> componentList;
  ComponentWidget({Key key, this.componentList}) : super(key: key);

  @override
  _ComponentWidgetState createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  List<AnimationStateImpl> componentList;

  Future<void> setComponentList() async {
    componentList = [];
    for (String path in widget.componentList) {
      AnimationStateImpl animImpl = await ImageUtils.getAnimationImage(path);
      componentList.add(animImpl);
    }
  }

  @override
  void initState() {
    super.initState();
    setComponentList().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return componentList == null
        ? CircularProgressIndicator()
        : GridView.builder(
            itemCount: componentList.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimateComponentWidget(
                  listImage: componentList[index].front);
            },
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          );
  }
}
