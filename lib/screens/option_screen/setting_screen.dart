import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/database/database.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/repository/repository.dart';
import 'package:gottask/utils/helper.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/screens/option_screen/about_me_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  final BuildContext ctx;

  const SettingScreen({Key key, @required this.ctx}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin, BlocCreator {
  AnimationController animationController;
  Animation animation;

  FirebaseRepository _repository;
  HandSide _handSide;
  HandSideBloc _handsideBloc;
  AllPokemonBloc _allPokemonBloc;
  TaskBloc _taskBloc;
  TodoBloc _todoBloc;
  FavouritePokemonBloc _favouritePokemonBloc;
  StarBloc _starBloc;
  bool _isInit = false;

  List<bool> _leftOrRight;

  // /// Is the API available on the device
  // bool _available = true;

  // /// The In App Purchase plugin
  // InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  // /// Products for sale
  // List<ProductDetails> _products = [];

  // /// Past purchase
  // List<PurchaseDetails> _purchases = [];

  // /// Initialize data
  // void _initialize() async {
  //   _available = await _iap.isAvailable();

  //   if (_available) {
  //     await _getProducts();

  //     // Verify and deliver a purchase with your own business logic
  //     _verifyPurchase();
  //   }
  // }

  // Future<void> _getProducts() async {
  //   Set<String> ids = Set.from(['remove_ads']);
  //   ProductDetailsResponse response = await _iap.queryProductDetails(ids);

  //   setState(() => _products = response.productDetails);
  // }

  // /// Your own business logic to setup a consumable
  // void _verifyPurchase() {
  //   PurchaseDetails purchase = _hasPurchased("remove_ads_id");

  //   // TODO serverside verification & record consumable in the database

  //   if (purchase != null && purchase.status == PurchaseStatus.purchased) {
  //     print("Has purchase!");
  //   }
  // }

  // PurchaseDetails _hasPurchased(String productID) {
  //   return _purchases.firstWhere((purchase) => purchase.productID == productID,
  //       orElse: () => null);
  // }

  // /// Purchase a product
  // void _buyProduct(ProductDetails prod) {
  //   final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
  //   _iap.buyNonConsumable(purchaseParam: purchaseParam).then((value) {
  //     print(value);
  //   });
  // }

  deleteAll() {
    _allPokemonBloc.pokemonStateList.forEach((state) {
      _allPokemonBloc.add(
        UpdatePokemonStateEvent(
          pokemonState: PokemonState(name: state.name, state: 0),
        ),
      );
    });

    List<Todo> _todoList = _todoBloc.todoList;
    _todoList.forEach((todo) =>
        _todoBloc.add(DeleteTodoEvent(todo: todo, addDeleteKey: false)));
    List<Task> _taskList = _taskBloc.taskList;
    TodoTable.deleteAllDeleteKey();
    _taskList.forEach((task) =>
        _taskBloc.add(DeleteTaskEvent(task: task, addDeleteKey: false)));
    TaskTable.deleteAllDeleteKey();
    _starBloc.add(SetStarEvent(
      starMap: {
        "addStar": 0,
        "loseStar": 0,
      },
    ));
    _favouritePokemonBloc.add(UpdateFavouritePokemonEvent(null));
  }

  initHandSide() async {
    _handSide = await currentHandSide();
    _refreshLeftOrRight();
  }

  _refreshLeftOrRight() {
    setState(() {
      if (_handSide == HandSide.Left)
        _leftOrRight = [true, false];
      else if (_handSide == HandSide.Right) _leftOrRight = [false, true];
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
    // _initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInit == false) {
      _handsideBloc = Provider.of<HandSideBloc>(widget.ctx);
      _repository = Provider.of<FirebaseRepository>(context);
      initHandSide();
      _allPokemonBloc = findBloc<AllPokemonBloc>();
      _favouritePokemonBloc = findBloc<FavouritePokemonBloc>();
      _starBloc = findBloc<StarBloc>();
      _todoBloc = findBloc<TodoBloc>();
      _taskBloc = findBloc<TaskBloc>();
      _isInit = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setting',
          style: TextStyle(
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AboutMeScreen(),
              ),
            ),
            icon: Icon(
              Feather.info,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Handside control ',
                      style: kTitleStyle,
                    ),
                    ToggleButtons(
                      isSelected:
                          _leftOrRight != null ? _leftOrRight : [false, false],
                      onPressed: (index) {
                        if (index == 0) {
                          _handSide = HandSide.Left;
                          _refreshLeftOrRight();
                          _handsideBloc
                              .add(HandSideChanged(handSide: _handSide));
                        } else {
                          _handSide = HandSide.Right;
                          _refreshLeftOrRight();
                          _handsideBloc
                              .add(HandSideChanged(handSide: _handSide));
                        }
                      },
                      children: <Widget>[
                        Text('L'),
                        Text('R'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // if (_products.isNotEmpty)
                //   InkWell(
                //     onTap: () {
                //       _buyProduct(_products[0]);
                //     },
                //     borderRadius: BorderRadius.circular(10),
                //     child: Container(
                //       height: 100,
                //       width: MediaQuery.of(context).size.width - 20,
                //       decoration: BoxDecoration(
                //         boxShadow: [
                //           BoxShadow(
                //             blurRadius: 10,
                //             color: TodoColors.lightGreen.withOpacity(0.5),
                //           ),
                //         ],
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(10),
                //         gradient: LinearGradient(
                //           colors: [
                //             TodoColors.lightGreen,
                //             TodoColors.lightOrange,
                //           ],
                //           begin: Alignment.topLeft,
                //           end: Alignment.bottomRight,
                //         ),
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Expanded(
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Text(
                //                   "Remove ads",
                //                   style: kMediumStyle.copyWith(
                //                     color: Colors.white,
                //                   ),
                //                 ),
                //                 Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Text(
                //                       "Buy me a coffee",
                //                       style: kMediumStyle.copyWith(
                //                         color: Colors.white,
                //                       ),
                //                     ),
                //                     SizedBox(width: 20),
                //                     Image.asset(
                //                       "assets/png/drink.png",
                //                       height: 50,
                //                     )
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //           ClipPath(
                //             clipper: PriceTag(),
                //             child: Container(
                //               width: 150,
                //               height: 40,
                //               decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 borderRadius: BorderRadius.circular(5),
                //               ),
                //               child: Center(
                //                 child: Padding(
                //                   padding: const EdgeInsets.only(right: 30),
                //                   child: Text(
                //                     "${_products[0].price}",
                //                     style: TextStyle(
                //                       fontFamily: "Source_Sans_Pro",
                //                       fontSize: 20,
                //                       fontWeight: FontWeight.bold,
                //                       color: TodoColors.lightGreen,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () async {
                  AuthServices _auth = AuthServices();
                  await _auth.signOut();
                  updateLoginState(false);
                  deleteAll();
                  _repository.initUser();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.popAndPushNamed(context, '/signIn');
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Sign out',
                    style: kMediumStyle.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceTag extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        size.width - 30,
        size.height,
        bottomLeft: Radius.circular(5),
        topLeft: Radius.circular(5),
      ),
    );
    path.moveTo(size.width - 30, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 30, size.height);
    path.lineTo(size.width - 30, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
