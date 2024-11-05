import 'package:colorful_progress_indicators/colorful_progress_indicators.dart';
import 'package:flutter/material.dart';

Widget customCirularProgress() {
    return const ColorfulCircularProgressIndicator(
      strokeWidth: 3.0,
            colors: [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
            ],
            duration:Duration(milliseconds: 500),
            initialColor: Colors.red,
          );
  }