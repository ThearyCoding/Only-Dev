import 'package:e_leaningapp/widgets/background-widget/custom_painter_matrix.dart';
import 'package:flutter/material.dart';


class MatrixBackground extends StatelessWidget {
  const MatrixBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.brightness == Brightness.dark
        ? Colors.black.withOpacity(.5)
        : Colors.black26;
    return CustomPaint(
      painter: MatrixPainter(context),
      child: Container(
        decoration: BoxDecoration(
          color: color,
        ),
      ),
    );
  }
}