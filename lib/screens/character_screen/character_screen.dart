import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gottask/database/hive/notemon_hive.dart';
import 'package:gottask/models/quantity_map_sprite_store.dart';
import 'package:gottask/models/sprite.dart';
import 'package:gottask/models/sprite_store.dart';
import 'package:gottask/screens/character_screen/widgets/animate_component_widget.dart';
import 'package:gottask/screens/character_screen/widgets/component_widget.dart';
import 'package:gottask/screens/character_screen/widgets/sprite_widget.dart';
import 'package:gottask/utils/character_helper.dart';
import 'package:gottask/utils/utils.dart';

class SpriteScreen extends StatefulWidget {
  SpriteScreen({Key key}) : super(key: key);

  @override
  _SpriteScreenState createState() => _SpriteScreenState();
}

class _SpriteScreenState extends State<SpriteScreen> {
  int componentIndex = 0;

  String currentComponent = "Body";
  String currentRarity = RarityState.trivial;

  SpriteStore store = NotemonHive.spriteData.store;
  Sprite sprite = NotemonHive.spriteData.sprite;
  AnimationState state = AnimationState.front;
  List<AnimationStateImpl> _previewList;

  List<Uint8List> _getPreviewImage(int index) {
    AnimationStateImpl preview = _previewList[index];

    switch (state) {
      case AnimationState.front:
        return preview.front;
      case AnimationState.back:
        return preview.back;
      case AnimationState.left:
        return preview.left;
      default:
        return preview.right;
    }
  }

  Future<void> setPreviewList() async {
    _previewList = [];
    for (String path in sprite.component.toJson().values) {
      if (path != null) {
        log(path, name: "Preview");
        AnimationStateImpl animImpl = await ImageUtils.getAnimationImage(path);
        _previewList.add(animImpl);
      } else {
        log("null", name: "Preview");
        _previewList.add(null);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setPreviewList().then((_) {
      log(_previewList.toString());
      WidgetsBinding.instance
          .addPostFrameCallback((timeStamp) => setState(() {}));
    });
  }

  int get componentListLength {
    Map<String, dynamic> json = NotemonHive.spriteData.quantityMapSpriteStore
        .toJson()[ComponentState.values[componentIndex]];
    RarityQuantity rarityQuantity = RarityQuantity.fromJson(json);

    switch (currentRarity) {
      case RarityState.trivial:
        return rarityQuantity.trivial;

      case RarityState.rare:
        return rarityQuantity.rare;

      default:
        return rarityQuantity.superrare;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: Get.height / 2,
              width: Get.width,
              color: FormatColor.fromHex(sprite.backgroundColor),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 50),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: TodoColors.blueMoon,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.map,
                                  color: TodoColors.blueMoon,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SpriteWidget(
                              fontSize: 17,
                              animationState: AnimationState.front,
                              scale: ((Get.height / 2) / 1.6) / 32,
                              sprite: NotemonHive.spriteData.sprite,
                              onChangeAnimationState: (newState) {
                                setState(() => state = newState);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: Get.width / 5,
              width: Get.width,
              margin: EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 15),
                physics: BouncingScrollPhysics(),
                itemCount: ComponentState.values.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () => setState(() {
                    componentIndex = index;
                    currentComponent = ComponentState.values[componentIndex];
                  }),
                  child: Container(
                    height: (Get.width - 6 * 10) / 5,
                    width: (Get.width - 6 * 10) / 5,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      children: [
                        Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: componentIndex != index
                                ? 0
                                : (Get.width - 6 * 10) / 5,
                            width: componentIndex != index
                                ? 0
                                : (Get.width - 6 * 10) / 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: componentIndex == index
                                ? (Get.width - 6 * 25) / 5
                                : (Get.width - 6 * 10) / 5,
                            width: componentIndex == index
                                ? (Get.width - 6 * 25) / 5
                                : (Get.width - 6 * 10) / 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: (Get.width - 6 * 25) / 5 * (1.25 / 3),
                                  width: (Get.width - 6 * 25) / 5 * (1.25 / 3),
                                  child: (_previewList.length != 0)
                                      ? (_previewList[index] != null)
                                          ? AnimateComponentWidget(
                                              listImage:
                                                  _getPreviewImage(index),
                                              scale: (Get.width - 6 * 25) /
                                                  5 *
                                                  (1.25 / 3) /
                                                  32,
                                            )
                                          : SizedBox(
                                              height: (Get.width - 6 * 25) /
                                                  5 *
                                                  (1.25 / 3),
                                              width: (Get.width - 6 * 25) /
                                                  5 *
                                                  (1.25 / 3),
                                            )
                                      : null,
                                ),
                                SizedBox(
                                  height: 10 *
                                      (Get.width - 6 * 25) /
                                      5 *
                                      (1.25 / 3) /
                                      32,
                                ),
                                Text(
                                  ComponentState.values[index]
                                      .replaceAll("_", " "),
                                  style: NotemonTextStyle.kRetroStyle.copyWith(
                                    fontSize: 7 *
                                        (Get.width - 6 * 25) /
                                        5 *
                                        (1.25 / 3) /
                                        32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: (Get.width - 6 * 10) / 5,
                      child: Column(
                        children: [
                          _rarityWidget(
                            rarity: RarityState.trivial,
                            color: Colors.green,
                          ),
                          SizedBox(height: 10),
                          _rarityWidget(
                            rarity: RarityState.rare,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 10),
                          _rarityWidget(
                            rarity: RarityState.superrare,
                            color: Colors.red[500],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: ComponentWidget(
                          key: Key(
                              "assets/characters/$currentComponent/$currentRarity/"),
                          componentList: List.generate(
                            componentListLength,
                            (index) =>
                                "assets/characters/$currentComponent/$currentRarity/${index + 1}.png",
                          ),
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

  Widget _rarityWidget({
    String rarity,
    Color color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => currentRarity = rarity),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.white70, Colors.white],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            rarity,
            style: NotemonTextStyle.kRetroStyle.copyWith(
              color: rarity == currentRarity ? Colors.white : Colors.white54,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
