import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

import 'package:only_dev_app/generated/l10n.dart';

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
        _showToast( connected ? AppLocalizations.current.internetConnectionRestored : AppLocalizations.current.internetConnectionLost,);

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
      _showToast(AppLocalizations.current.internetConnectionLost);
    });
  }

  void _showToast(String message) {
    AppToastUtils.show(message);
  }

  @override
  void dispose() {
    _connectionLostTimer?.cancel();
    super.dispose();
  }
}
