import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
                type,
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
                        int.parse(pokedex[widget.currentPokemon][type]) /
                        160,
                height: 30,
                color: tagColor[pokedex[widget.currentPokemon]['type'][0]],
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
                      ' ${pokedex[widget.currentPokemon][type]}',
                      style: TextStyle(
                        fontFamily: 'Alata',
                        color: tagColor['Water'],
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
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
                  'Height',
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
                      : pokedex[widget.currentPokemon]['height'],
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
                  'Weight',
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
                      : pokedex[widget.currentPokemon]['weight'],
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
                  'Category',
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
                      : pokedex[widget.currentPokemon]['category'],
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
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'Type',
            style: TextStyle(
              fontFamily: 'Alata',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            children: List.generate(
              pokedex[widget.currentPokemon]['type'].length,
              (index) => PetTagCustom(
                nameTag: pokedex[widget.currentPokemon]['type'][index],
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
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'Weaknesses',
            style: TextStyle(
              fontFamily: 'Alata',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            children: List.generate(
              pokedex[widget.currentPokemon]['weaknesses'].length,
              (index) => PetTagCustom(
                nameTag: pokedex[widget.currentPokemon]['weaknesses'][index],
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
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'Strength index',
            style: TextStyle(
              fontFamily: 'Alata',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        widget.pokemonState.state == 1
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
        Padding(
          padding: const EdgeInsets.only(
            left: 15,
          ),
          child: Text(
            'Introduction',
            style: TextStyle(
              fontFamily: 'Alata',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        widget.pokemonState.state == 1
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: Text(
                  pokedex[widget.currentPokemon]['introduction'],
                  style: TextStyle(
                    fontFamily: 'Monsterrat',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none,
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width * 3 / 4,
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  left: 10,
                  right: 10,
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
