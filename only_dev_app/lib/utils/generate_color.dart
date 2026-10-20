import 'package:flutter/material.dart';
import 'dart:math' as math;

class GenerateColor {
  // Function to generate a random color, avoiding black and white
  static Color generateRandomColor() {
    int red = math.Random().nextInt(156) + 50; // Ranges from 50 to 205
    int green = math.Random().nextInt(156) + 50; // Ranges from 50 to 205
    int blue = math.Random().nextInt(156) + 50; // Ranges from 50 to 205
    return Color.fromRGBO(red, green, blue, 1.0);
  }

  // Backward compatibility no-op
  static Future<void> onUserLogin() async {}

  // Function to determine if the background color is light or dark
  static Color getContrastingTextColor(Color backgroundColor) {
    double brightness = (backgroundColor.red * 0.299 +
            backgroundColor.green * 0.587 +
            backgroundColor.blue * 0.114) /
        255;
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  // Generate a random gradient color
  static Gradient generateRandomGradient() {
    return LinearGradient(
      colors: [
        generateRandomColor(),
        generateRandomColor(),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}