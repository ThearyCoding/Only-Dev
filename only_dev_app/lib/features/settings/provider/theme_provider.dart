import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/theme/custom_theme.dart';

class CustomizeThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.dark;
  final String _storageKey = 'isdarkMode';
  SharedPreferences? _prefs;

  ThemeMode get currentTheme => _currentTheme;

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

  void switchTheme(BuildContext context) {
    _currentTheme =
        _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    _saveThemeToStorage(_currentTheme);

    ThemeSwitcher.of(context).changeTheme(
      theme: _currentTheme == ThemeMode.dark
          ? CustomThemes.darkTheme
          : CustomThemes.lightTheme,
      isReversed: _currentTheme == ThemeMode.light,
    );

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
