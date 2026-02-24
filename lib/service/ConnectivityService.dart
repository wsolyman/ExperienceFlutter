// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    // Listen to connectivity changes - CORRECTED VERSION
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkInternetConnection();
    });

    // Initial check
    await _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    connectionStatusController.add(hasConnection);
  }

  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  void dispose() {
    connectionStatusController.close();
  }
}