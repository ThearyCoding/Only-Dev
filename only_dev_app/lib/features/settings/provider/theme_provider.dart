import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/di/dependency_injection.dart';

class CustomizeThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.dark;
  final String _storageKey = 'isdarkMode';
  SharedPreferences? _prefs;

  ThemeMode get currentTheme => _currentTheme;

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  CustomizeThemeProvider() {
    _initTheme();
  }

  void _initTheme() {
    try {
      _prefs = locator<SharedPreferences>();
      _currentTheme = getThemeModeFromStorage();
    } catch (_) {
      _currentTheme = ThemeMode.dark;
    }
  }

  Future<void> loadTheme() async {
    _initTheme();
  }

  void switchTheme([BuildContext? context]) {
    _currentTheme =
        _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    _saveThemeToStorage(_currentTheme);
    notifyListeners();
  }

  ThemeMode getThemeModeFromStorage() {
    bool isDarkMode = _prefs?.getBool(_storageKey) ?? true;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _saveThemeToStorage(ThemeMode themeMode) {
    _prefs?.setBool(_storageKey, themeMode == ThemeMode.dark);
  }
}
