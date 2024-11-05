import 'package:flutter/material.dart';
class UnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final underlineY = size.height / 2 + paint.strokeWidth;

    canvas.drawLine(
      Offset(0, underlineY),
      Offset(size.width, underlineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}