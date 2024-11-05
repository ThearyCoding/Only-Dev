import 'package:flutter/material.dart';

class CustomThemes {
  static final lightTheme = ThemeData(
    primaryColor: Colors.blue,
    useMaterial3: false,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      surface: const Color(0xffECECEC),
      secondary: Colors.grey[300]!,
      primaryContainer: Colors.blueAccent,
    ),
     
    appBarTheme: const AppBarTheme(
      
      backgroundColor: Colors.blue,
      iconTheme: IconThemeData(color: Colors.grey),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: 'NotoSansKhmer'
      )
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
    primaryColor: Colors.blueGrey,
    useMaterial3: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff171717),
    colorScheme: ColorScheme.dark(
      surface: const Color(0xff212121),
      secondary: Colors.grey[800]!,
      primaryContainer: Colors.blueAccent,
    
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
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
