import 'package:flutter/material.dart';
import 'package:only_dev_app/core/app_style.dart';

class CustomThemes {
  static final lightTheme = ThemeData(
    primaryColor: AppStyle.primaryColor,
    useMaterial3: false,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppStyle.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppStyle.primaryColor,
      surface: AppStyle.lightSurface,
      secondary: Color(0xffE0E0E0),
      primaryContainer: AppStyle.primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppStyle.primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontFamily: 'NotoSansKhmer',
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), 
      bodyMedium: TextStyle(color: Colors.black87),
      displayLarge: TextStyle(color: Colors.black),
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87), 
      displayLarge: TextStyle(color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: Colors.black), 
    primaryIconTheme: const IconThemeData(color: Colors.grey),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppStyle.primaryColor,
    useMaterial3: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppStyle.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppStyle.primaryColor,
      surface: AppStyle.darkSurface,
      secondary: Colors.grey[800]!,
      primaryContainer: AppStyle.primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppStyle.darkBackground,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), 
      bodyMedium: TextStyle(color: Colors.white70), 
      displayLarge: TextStyle(color: Colors.white),
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      displayLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(
        color: Colors.grey),
    primaryIconTheme: IconThemeData(
      color: Colors.white.withOpacity(.9),
    ),
  );
}
