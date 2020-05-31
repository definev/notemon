import 'dart:io'; //InternetAddress utility
import 'dart:async'; //For StreamController / Stream

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

Future<bool> checkConnection() async {
  if (kIsWeb) return true;
  bool connection = false;

  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      connection = true;
    } else {
      connection = false;
    }
  } on SocketException catch (_) {
    connection = false;
  }
  return connection;
}

class ConnectionStatusSingleton {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatusSingleton _singleton =
      ConnectionStatusSingleton._internal();
  ConnectionStatusSingleton._internal();

  //This is what's used to retrieve the instance through the app
  static ConnectionStatusSingleton getInstance() => _singleton;

  //This tracks the current connection status
  bool hasConnection = false;

  //This is how we'll allow subscribing to connection changes
  StreamController<bool> connectionChangeController =
      StreamController<bool>.broadcast();

  //flutter_connectivity
  final Connectivity _connectivity = Connectivity();

  //Hook into flutter_connectivity's Stream to listen for changes
  //And check the connection status out of the gate
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkOutConnection();
    connectionChangeController.add(hasConnection);
  }

  Stream get connectionChange => connectionChangeController.stream;

  //A clean up method to close our StreamController<bool>
  //   Because this is meant to exist through the entire application life cycle this isn't
  //   really an issue
  void dispose() {
    connectionChangeController.close();
  }

  //flutter_connectivity's listener
  void _connectionChange(ConnectivityResult result) {
    checkOutConnection();
  }

  //The test to actually see if there is a connection
  Future<bool> checkOutConnection() async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    //The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
