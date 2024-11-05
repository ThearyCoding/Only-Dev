import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
class GenerateColor {
  static final FirebaseFirestore _firestore = locator<FirebaseFirestore>();
  static final User? _user = locator<FirebaseAuth>().currentUser;

  // Function to generate a random color, avoiding black and white
  static Color generateRandomColor() {
    // Define color ranges to avoid very light or very dark colors
    int red = math.Random().nextInt(156) + 50; // Ranges from 50 to 205
    int green = math.Random().nextInt(156) + 50; // Ranges from 50 to 205
    int blue = math.Random().nextInt(156) + 50; // Ranges from 50 to 205
    return Color.fromRGBO(red, green, blue, 1.0);
  }

  // Save generated color to Firestore when a user logs in and doesn't have a photoURL
  static Future<void> onUserLogin() async {
  if (_user != null) {
    // Fetch the user document from Firestore
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();

    // Check if the document exists and cast its data to Map<String, dynamic>
    if (!userDoc.exists || !(userDoc.data() as Map<String, dynamic>).containsKey('backgroundColor')) {
      // Generate a random background color if none exists
      Color userColor = generateRandomColor();
      String colorHex = '#${userColor.value.toRadixString(16).padLeft(6, '0')}';

      // Save the generated color to Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'backgroundColor': colorHex,
      }, SetOptions(merge: true));
    }
  }
}


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