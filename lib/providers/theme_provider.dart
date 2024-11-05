import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';

import '../export/export.dart';

class CustomizeThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.system;
  final String _storageKey = 'isdarkMode';
  SharedPreferences? _prefs;

  ThemeMode get currentTheme => _currentTheme;

  CustomizeThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _currentTheme = getThemeModeFromStorage();
    notifyListeners();
  }

  void switchTheme(BuildContext context) {
    _currentTheme = _currentTheme == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    _saveThemeToStorage(_currentTheme);

    ThemeSwitcher.of(context).changeTheme(
      theme: _currentTheme == ThemeMode.dark
          ? CustomThemes.darkTheme
          : CustomThemes.lightTheme,
      isReversed: _currentTheme == ThemeMode.light,
    );

  //  notifyListeners();
  }

  ThemeMode getThemeModeFromStorage() {
    bool isDarkMode = _prefs?.getBool(_storageKey) ?? true;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _saveThemeToStorage(ThemeMode themeMode) {
    _prefs?.setBool(_storageKey, themeMode == ThemeMode.dark);
  }
}
