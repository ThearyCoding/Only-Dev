import 'package:e_leaningapp/core/global_navigation.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

import '../generated/l10n.dart';

class InternetConnectionProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  Timer? _connectionLostTimer;

  InternetConnectionProvider() {
    _listenToInternetConnectionStatus();
  }

  void _listenToInternetConnectionStatus() {
    InternetConnectionCheckerPlus().onStatusChange.listen((event) {
      final bool connected = event == InternetConnectionStatus.connected;
      
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
        _showSnackbar( connected ? S.current.internetConnectionRestored : S.current.internetConnectionLost,);

        if (!connected) {
          _startConnectionLostTimer();
        } else {
          _connectionLostTimer?.cancel();
        }
      }
    });
  }

  void _startConnectionLostTimer() {
    _connectionLostTimer?.cancel();
    _connectionLostTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _showSnackbar(S.current.internetConnectionLost);
    });
  }

  void _showSnackbar(String message) {
    final context = navigatorKey.currentState!.context;
    if (context != null) {
      showSnackbar(message);
    }
  }

  @override
  void dispose() {
    _connectionLostTimer?.cancel();
    super.dispose();
  }
}
