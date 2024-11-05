import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});


  @override
  AnimatedBackgroundState createState() => AnimatedBackgroundState();
}

class AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<Offset> points = [];
  List<Offset> velocities = [];
  List<Color> pointColors = [];
  final int numberOfPoints = 50;
  Color backgroundColor = Colors.black;
  double hue = 0.0;

  @override
  void initState() {
    super.initState();

    final random = Random();
    for (int i = 0; i < numberOfPoints; i++) {
      points.add(Offset(random.nextDouble() * 500, random.nextDouble() * 800));
      velocities.add(Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1));
      pointColors.add(HSVColor.fromAHSV(1.0, random.nextDouble() * 360, 1.0, 1.0).toColor());
    }

    _ticker = createTicker((_) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < points.length; i++) {
            points[i] = points[i] + velocities[i];
            if (points[i].dx > 500 || points[i].dx < 0) {
              velocities[i] = Offset(-velocities[i].dx, velocities[i].dy);
            }
            if (points[i].dy > 800 || points[i].dy < 0) {
              velocities[i] = Offset(velocities[i].dx, -velocities[i].dy);
            }
          }

          hue = (hue + 0.5) % 360;
          backgroundColor = HSVColor.fromAHSV(1.0, hue, 0.6, 0.8).toColor();
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: CustomPaint(
        painter: NetworkPainter(points, pointColors),
        child: Container(),
      ),
    );
  }
}

class NetworkPainter extends CustomPainter {
  final List<Offset> points;
  final List<Color> pointColors;
  NetworkPainter(this.points, this.pointColors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5;

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < 100) {
          paint.color = Colors.white.withOpacity(1 - (distance / 100));
          canvas.drawLine(points[i], points[j], paint);
        }
      }
    }

    for (int i = 0; i < points.length; i++) {
      paint.color = pointColors[i];
      canvas.drawCircle(points[i], 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
