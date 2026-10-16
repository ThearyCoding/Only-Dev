import 'package:flutter/foundation.dart';

enum ViewState { idle, busy, error, success }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _disposed = false;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _state == ViewState.busy;
  bool get hasError => _state == ViewState.error && _errorMessage != null;
  bool get isSuccess => _state == ViewState.success;
  bool get isDisposed => _disposed;

  void setViewState(ViewState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  void setBusy(bool busy) {
    if (_disposed) return;
    if (busy) {
      _state = ViewState.busy;
      _errorMessage = null;
    } else if (_state == ViewState.busy) {
      _state = ViewState.idle;
    }
    notifyListeners();
  }

  void setError(String message) {
    if (_disposed) return;
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    _state = ViewState.idle;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

