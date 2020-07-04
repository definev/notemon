import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/screens/option_screen/setting_screen.dart';
import 'package:gottask/screens/pokemon_screen/pokemon_info.dart';
import 'package:swipedetector/swipedetector.dart';

class AllPokemonScreen extends StatefulWidget {
  final int currentPokemon;

  AllPokemonScreen({this.currentPokemon});
  @override
  _AllPokemonScreenState createState() => _AllPokemonScreenState();
}

class _AllPokemonScreenState extends State<AllPokemonScreen>
    with
        AfterLayoutMixin<AllPokemonScreen>,
        BlocCreator,
        SingleTickerProviderStateMixin {
  int _currentPokemon = 0;
  int _currentStarPoint = 0;
  int _amount = 5;

  bool _isInit = false;
  bool _isLoaded = false;
  bool _isConnect = false;

  ScrollController _scrollController = FixedExtentScrollController();
  HandSide _currentHandside;

  AllPokemonBloc _allPokemonBloc;
  StarBloc _starBloc;
  FirebaseRepository _repository;
  FavouritePokemonBloc _favouritePokemonBloc;
  HandSideBloc _handsideBloc;

  int _videoWatched = 0;

  AnimationController _animationController;

  getCurrentHandside() async => _currentHandside = await currentHandSide();

  adsButton() =>
      (_isConnect == true && _isLoaded == true) ? _adsContainer() : Container();

  SafeArea _adsContainer() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () async {
              await _showAdsWarning();
            },
            child: Material(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.orange[50],
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: TodoColors.scaffoldWhite,
                        ),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              tileMode: TileMode.repeated,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.1, 0.3, 1],
                              colors: <Color>[
                                Colors.white,
                                tagColor['Flying'],
                                tagColor['Water'],
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.modulate,
                          child: Text(
                            'Ads',
                            style: kNormalSuperSmallStyle.copyWith(
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Text(
                        'You can watch ads for support me ^^',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width / 38,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            tileMode: TileMode.repeated,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Colors.yellow,
                              Colors.deepOrange.shade500,
                              Colors.yellow,
                            ],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.modulate,
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  _showAdsWarning() async => showDialog(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              height: 200,
              width: 400,
              decoration: BoxDecoration(
                color: TodoColors.scaffoldWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Text(
                    'You will get $_amount stars!',
                    style: kBigTitleStyle.copyWith(fontWeight: FontWeight.w200),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width > 200
                                ? 130
                                : 100,
                            margin: const EdgeInsets.only(
                              left: 10,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  tagColor[pokedex[_currentPokemon]['type'][0]],
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style:
                                    kTitleStyle.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final result =
                                  await InternetAddress.lookup('google.com');
                              if (result.isNotEmpty &&
                                  result[0].rawAddress.isNotEmpty) {
                                RewardedVideoAd.instance.show();
                              }
                            } on SocketException catch (_) {} on PlatformException catch (_) {}

                            Navigator.pop(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width > 200
                                ? 130
                                : 80,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  tagColor[pokedex[_currentPokemon]['type'][0]],
                            ),
                            child: Center(
                              child: Text(
                                'Watch ads',
                                style:
                                    kTitleStyle.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  checkConnect() async {
    _videoWatched = await getVideoReward();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) setState(() => _isConnect = true);
      }
    } on SocketException catch (_) {
      if (mounted) setState(() => _isConnect = false);
    }
  }

  rewardedVideoAdSetup() async {
    FirebaseAdMob.instance.initialize(appId: appId);

    _isLoaded = await getLoadAdsInfirst();
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      // print('Reward video event: $event');

      if (event == RewardedVideoAdEvent.rewarded) {
        _starBloc.add(AddStarEvent(point: _amount));
        updateVideoReward();
        setState(() {
          _currentStarPoint += _amount;
          _videoWatched++;
        });
      }

      if (event == RewardedVideoAdEvent.failedToLoad && mounted) {
        setLoadAdsInfirst(false);
      }

      if (event == RewardedVideoAdEvent.loaded) {
        setLoadAdsInfirst(true);
        if (mounted) setState(() => _isLoaded = true);
      }

      if (event == RewardedVideoAdEvent.closed && mounted) {
        setState(() => _isLoaded = false);
        RewardedVideoAd.instance.load(
          adUnitId: rewardId,
          targetingInfo: targetingInfo,
        );
      }
    };
    if (_isLoaded == false) {
      RewardedVideoAd.instance.load(
        adUnitId: rewardId,
        targetingInfo: targetingInfo,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    rewardedVideoAdSetup();
    _currentPokemon = widget.currentPokemon;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1, milliseconds: 400),
    );
    _animationController.addListener(() async {
      if (_animationController.value == 1 &&
          _animationController.status == AnimationStatus.completed) {
        await AudioCache().play(audioFile['Level_Up']);
        _starBloc.add(BuyItemEvent(point: 30));
        _allPokemonBloc.add(
          UpdatePokemonStateEvent(
            pokemonState: PokemonState(
              name: pokedex[_currentPokemon]['name'],
              state: 1,
            ),
          ),
        );
        if (await checkConnection()) {
          _repository.updatePokemonStateToFirebase(PokemonState(
            name: pokedex[_currentPokemon]['name'],
            state: 1,
          ));
        }
        _currentStarPoint -= 30;
        _animationController.reverse();
      }
      setState(() {});
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            MediaQuery.of(context).size.width / 4 * _currentPokemon,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) {
      _allPokemonBloc = findBloc<AllPokemonBloc>();
      _starBloc = findBloc<StarBloc>();
      _favouritePokemonBloc = findBloc<FavouritePokemonBloc>();
      _handsideBloc = findBloc<HandSideBloc>();
      _repository = findBloc<FirebaseRepository>();
      _allPokemonBloc.add(InitAllPokemonEvent());
      _handsideBloc.add(InitHandSide());
      getCurrentHandside();
      checkConnect();
      _currentStarPoint = _starBloc.currentStarPoint;
      _isInit = true;
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: BlocBuilder<HandSideBloc, HandSideState>(
        bloc: _handsideBloc,
        builder: (context, state) {
          if (state is HandSideLoaded) {
            if (_currentHandside != state.handSide) {
              _refresh(context);
              _currentHandside = state.handSide;
            }
            if (state.handSide == HandSide.Left) {
              return _handWidget(context: context, isLeft: true);
            } else
              return _handWidget(context: context, isLeft: false);
          }
          return _buildWaiting(context);
        },
      ),
    );
  }

  SwipeDetector _handWidget({BuildContext context, bool isLeft}) {
    return SwipeDetector(
      onSwipeRight: () => Navigator.pop(context),
      onSwipeLeft: () => Navigator.pop(context),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.decelerate,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: tagColor[pokedex[_currentPokemon]['type'][0]].withOpacity(0.6),
        ),
        child: BlocBuilder<AllPokemonBloc, AllPokemonState>(
          bloc: _allPokemonBloc,
          builder: (context, state) {
            if (state is AllPokemonLoaded) {
              if (state.pokemonStateList.isEmpty)
                return Center(
                  child: Text('Waiting ...'),
                );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isLeft
                    ? [
                        _buildWheelPokemon(context, state.pokemonStateList,
                            isLeft: true),
                        _pokemonDetail(context, state.pokemonStateList),
                      ]
                    : [
                        _pokemonDetail(context, state.pokemonStateList),
                        _buildWheelPokemon(context, state.pokemonStateList,
                            isLeft: false),
                      ],
              );
            }
            return Center(
              child: Text('Waiting ...'),
            );
          },
        ),
      ),
    );
  }

  Flexible _pokemonDetail(BuildContext context, List<PokemonState> snapshot) {
    return Flexible(
      flex: 3,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (_isConnect == true && _videoWatched < 4) adsButton(),
            SizedBox(height: MediaQuery.of(context).size.height / 7 - 20),
            Center(
              child: Image.asset(
                pokedex[_currentPokemon]["imageURL"],
                height: MediaQuery.of(context).size.height / 4,
                color: snapshot[_currentPokemon].state == 0
                    ? Colors.black45
                    : null,
                colorBlendMode: snapshot[_currentPokemon].state == 0
                    ? BlendMode.modulate
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              child: SizedBox(
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: snapshot[_currentPokemon].state == 0
                      ? [hideName(), _buyButton()]
                      : [
                          Text(
                            pokedex[_currentPokemon]['name'],
                            style: TextStyle(
                              fontFamily: 'Alata',
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 35
                                  : 26,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          _buildFavouriteButton(),
                        ],
                ),
              ),
            ),
            _buildInfoPokemon(context, snapshot[_currentPokemon]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPokemon(BuildContext context, PokemonState state) {
    return PokemonInfo(
      currentPokemon: _currentPokemon,
      pokemonState: state,
    );
  }

  Container hideName() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Icon(
        SimpleLineIcons.question,
        color: Colors.black38,
      ),
    );
  }

  Widget _buyButton() => GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) {
          if (_animationController.status == AnimationStatus.forward) {
            _animationController.reverse();
          }
        },
        child: Transform(
          transform: _animationController.status != AnimationStatus.completed
              ? Matrix4.skewX(-_animationController.value * 0.15)
              : Matrix4.identity(),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.amber[50],
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 5),
                width: MediaQuery.of(context).size.width / 2.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Hold to unlock',
                      style: kNormalSmallStyle.copyWith(
                        color: _currentStarPoint >= 30
                            ? TodoColors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '30 ',
                          style: kNormalSmallStyle.copyWith(
                            color: _currentStarPoint >= 30
                                ? TodoColors.deepPurple
                                : Colors.grey,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Image.asset(
                          'assets/png/star.png',
                          height: 12,
                          color: _currentStarPoint >= 30
                              ? null
                              : Colors.black.withOpacity(0.3),
                          colorBlendMode: _currentStarPoint >= 30
                              ? null
                              : BlendMode.modulate,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _animationController.value *
                      MediaQuery.of(context).size.width /
                      2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: _animationController.value < 0.95
                          ? Radius.circular(0)
                          : Radius.circular(5),
                    ),
                    color: TodoColors.deepPurple,
                  ),
                  height: 5,
                ),
              ),
            ],
          ),
        ),
      );

  Flexible _buildWheelPokemon(BuildContext context, List<PokemonState> snapshot,
          {bool isLeft}) =>
      Flexible(
        flex: 1,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: FractionalOffset.center,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 3.1 / 5,
                child: ListWheelScrollView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  // offAxisFraction: isLeft ? 4 : -4,
                  onSelectedItemChanged: (value) =>
                      setState(() => _currentPokemon = value),
                  children: List.generate(
                    pokedex.length,
                    (index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: TodoColors.deepPurple,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 75,
                          vertical: MediaQuery.of(context).size.width / 200,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Stack(
                          children: <Widget>[
                            Image.asset(
                              pokedex[index]["imageURL"],
                              height:
                                  MediaQuery.of(context).size.width / 4 - 10,
                              color: snapshot[index].state == 0
                                  ? Colors.black54
                                  : null,
                              colorBlendMode: snapshot[index].state == 0
                                  ? BlendMode.modulate
                                  : null,
                            ),
                            if (snapshot[index].state == 0)
                              Align(
                                alignment: FractionalOffset.center,
                                child: Icon(
                                  AntDesign.question,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  itemExtent: MediaQuery.of(context).size.width / 4,
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: isLeft
                    ? FractionalOffset.bottomLeft
                    : FractionalOffset.bottomRight,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: MediaQuery.of(context).size.width / 40,
                  ),
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isLeft)
                        Material(
                          child: Text(
                            _allPokemonBloc.pokemonStateList.collectedPokemon(),
                            style: kNormalSuperSmallStyle.copyWith(
                                color: TodoColors.deepPurple),
                          ),
                        ),
                      GestureDetector(
                        child: Icon(
                          Icons.settings,
                          color: Colors.black45,
                          size: 25,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingScreen(ctx: context),
                            ),
                          );
                        },
                      ),
                      if (isLeft)
                        Material(
                          child: Text(
                            _allPokemonBloc.pokemonStateList.collectedPokemon(),
                            style: kNormalSuperSmallStyle.copyWith(
                                color: TodoColors.deepPurple),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: FractionalOffset.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: isLeft
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: <Widget>[
                          Material(
                            child: Text(
                              '$_currentStarPoint ',
                              style: kNormalSmallStyle,
                            ),
                          ),
                          Image.asset(
                            'assets/png/star.png',
                            height: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Future<dynamic> _refresh(BuildContext context) {
    return Future.delayed(
      Duration(milliseconds: 100),
      () {
        setState(() {});
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            MediaQuery.of(context).size.width / 4 * _currentPokemon,
          );
        }
      },
    );
  }

  Container _buildWaiting(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
    );
  }

  Widget _buildFavouriteButton() {
    return Container(
      margin: const EdgeInsets.all(3),
      child: _favouritePokemonBloc.favouritePokemon != _currentPokemon
          ? GestureDetector(
              onTap: () {
                _favouritePokemonBloc
                    .add(UpdateFavouritePokemonEvent(_currentPokemon));
                _repository.updateFavouritePokemon(_currentPokemon);
                setState(() {
                  _favouritePokemonBloc.favouritePokemon = _currentPokemon;
                });
              },
              child: Icon(
                AntDesign.hearto,
                color: Colors.black45,
                size: 30,
              ),
            )
          : GestureDetector(
              onTap: () {
                _favouritePokemonBloc.add(UpdateFavouritePokemonEvent(-1));
                _repository.updateFavouritePokemon(-1);
                setState(() {
                  _favouritePokemonBloc.favouritePokemon = -1;
                });
              },
              child: Icon(
                AntDesign.heart,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
    );
  }
}
