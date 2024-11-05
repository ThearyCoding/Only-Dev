import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;

  const AnimatedGradientContainer({required this.child, Key? key})
      : super(key: key);

  @override
  AnimatedGradientContainerState createState() =>
      AnimatedGradientContainerState();
}

class AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  final List<List<Color>> _gradientColors = [
    [Colors.red, Colors.orange],
    [Colors.orange, Colors.yellow],
    [Colors.yellow, Colors.green],
    [Colors.green, Colors.blue],
    [Colors.blue, Colors.purple],
    [Colors.purple, Colors.red],
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _gradientColors.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: _gradientColors[_currentIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: widget.child,
    );
  }
}
