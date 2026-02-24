// lib/screens/main_wrapper.dart
import 'package:experience/service/ConnectivityService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'NoInternetScreen.dart';
class MainWrapper extends StatefulWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late ConnectivityService _connectivityService;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivityService.connectionStatusController.stream.listen((status) {
      if (mounted) {
        setState(() {
          _hasInternet = status;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    bool hasConnection = await _connectivityService.checkConnection();
    if (mounted) {
      setState(() {
        _hasInternet = hasConnection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return NoInternetScreen(
        onRetry: _checkConnection,
      );
    }

    return widget.child;
  }
}