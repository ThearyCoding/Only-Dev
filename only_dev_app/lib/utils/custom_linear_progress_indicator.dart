
import 'package:flutter/material.dart';

class CustomLinearProgressIndicator extends StatefulWidget {
  const CustomLinearProgressIndicator({super.key});

  @override
  CustomLinearProgressIndicatorState createState() => CustomLinearProgressIndicatorState();
}

class CustomLinearProgressIndicatorState extends State<CustomLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _controller.repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 1.0,
              width: double.infinity,
              color: Colors.white.withOpacity(0.2),
            ),
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: _controller.value / 1,
                child: Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _controller.value / 1,
                child: Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
