import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:gottask/components/pet_tag_custom.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/models/pokemon_state.dart';

class PokemonInfo extends StatefulWidget {
  final PokemonState pokemonState;
  final int currentPokemon;
  PokemonInfo({this.pokemonState, this.currentPokemon});

  @override
  _PokemonInfoState createState() => _PokemonInfoState();
}

class _PokemonInfoState extends State<PokemonInfo> {
  Widget _buildRowStatic(BuildContext context, String type) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            child: Material(
              child: Text(
                type.tr,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: MediaQuery.of(context).size.width / 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              AnimatedContainer(
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                duration: Duration(milliseconds: 600),
                curve: Curves.decelerate,
                color: Colors.white.withOpacity(0.6),
                width: MediaQuery.of(context).size.width * 3 / 4 * 3 / 4 - 20,
                height: 30,
              ),
              AnimatedContainer(
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                duration: Duration(milliseconds: 600),
                curve: Curves.decelerate,
                width:
                    (MediaQuery.of(context).size.width * 3 / 4 * 3 / 4 - 20) *
                        pokedex[widget.currentPokemon].getInfoByType(type) /
                        160,
                height: 30,
                color: tagColor[pokedex[widget.currentPokemon].type.en[0]],
              ),
              AnimatedContainer(
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                duration: Duration(milliseconds: 600),
                curve: Curves.decelerate,
                width: MediaQuery.of(context).size.width * 3 / 4 * 3 / 4 - 20,
                height: 30,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Align(
                    alignment: FractionalOffset.centerRight,
                    child: Text(
                      ' ${pokedex[widget.currentPokemon].getInfoByType(type)}',
                      style: NotemonTextStyle.kNormalSuperSmallStyle
                          .copyWith(color: tagColor['Water']),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        text.tr,
        style: NotemonTextStyle.kTitleStyle.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  'Height'.tr,
                  style: TextStyle(
                    fontFamily: 'Alata',
                    color: TodoColors.deepPurple,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 20,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  widget.pokemonState.state == 0
                      ? '?'
                      : pokedex[widget.currentPokemon].height,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 25,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  'Weight'.tr,
                  style: TextStyle(
                    fontFamily: 'Alata',
                    color: TodoColors.deepPurple,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 20,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  widget.pokemonState.state == 0
                      ? '?'
                      : pokedex[widget.currentPokemon].weight,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 25,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  'Category'.tr,
                  style: TextStyle(
                    fontFamily: 'Alata',
                    color: TodoColors.deepPurple,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 20,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  widget.pokemonState.state == 0
                      ? '?'
                      : pokedex[widget.currentPokemon].category,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 25,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ),
        _title('Type'),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            children: List.generate(
              pokedex[widget.currentPokemon].type.en.length,
              (index) => PetTagCustom(
                colorTag: pokedex[widget.currentPokemon].type.en[index],
                nameTag: Get.locale.languageCode == 'en'
                    ? pokedex[widget.currentPokemon].type.en[index]
                    : pokedex[widget.currentPokemon].type.vi[index],
                height: 35,
                width: MediaQuery.of(context).size.width * 2 / 3 / 2,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 25,
                  fontFamily: 'Alata',
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        _title('Weaknesses'),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            children: List.generate(
              pokedex[widget.currentPokemon].weaknesses.en.length,
              (index) => PetTagCustom(
                colorTag: pokedex[widget.currentPokemon].weaknesses.en[index],
                nameTag: Get.locale.languageCode == 'en'
                    ? pokedex[widget.currentPokemon].weaknesses.en[index]
                    : pokedex[widget.currentPokemon].weaknesses.vi[index],
                height: 35,
                width: MediaQuery.of(context).size.width * 2 / 3 / 2,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 25,
                  fontFamily: 'Alata',
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        _title('Strength index'),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: widget.pokemonState.state == 1
              ? Column(
                  children: <Widget>[
                    _buildRowStatic(context, 'HP'),
                    _buildRowStatic(context, 'Attack'),
                    _buildRowStatic(context, 'Defense'),
                    _buildRowStatic(context, 'Speed'),
                    _buildRowStatic(context, 'Sp Atk'),
                    _buildRowStatic(context, 'Sp Def'),
                  ],
                )
              : Container(
                  width: MediaQuery.of(context).size.width * 3 / 4,
                  height: 40.0 * 6,
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: widget.pokemonState.state == 0
                        ? Colors.white30
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      SimpleLineIcons.question,
                      color: Colors.black38,
                      size: 40,
                    ),
                  ),
                ),
        ),
        _title('Introduction'),
        widget.pokemonState.state == 1
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 15,
                  bottom: 10,
                ),
                child: Text(
                  Get.locale.languageCode == 'en'
                      ? pokedex[widget.currentPokemon].introduction.en
                      : pokedex[widget.currentPokemon].introduction.vi,
                  style: NotemonTextStyle.kNormalSmallStyle.copyWith(
                    fontFamily: 'Source_Sans_Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width * 3 / 4,
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 10,
                  right: 15,
                ),
                decoration: BoxDecoration(
                  color: widget.pokemonState.state == 0
                      ? Colors.white30
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Icon(
                      SimpleLineIcons.question,
                      color: Colors.black38,
                      size: 40,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
