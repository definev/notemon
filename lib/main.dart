import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gottask/app.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchases();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}
