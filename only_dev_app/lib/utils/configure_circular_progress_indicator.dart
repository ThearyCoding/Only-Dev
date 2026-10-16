import 'package:flutter/material.dart';

class ConfigureCircularProgressIndicator extends StatelessWidget {
  const ConfigureCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isdarkMode = Theme.of(context).brightness== Brightness.dark;
    return CircularProgressIndicator(
      strokeWidth: 1.0,
      color: isdarkMode ? Colors.white: Colors.black,
    );
  }
}