import 'package:flutter/material.dart';

class MatrixPainter extends CustomPainter {
  final BuildContext context;

  MatrixPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.black26;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}