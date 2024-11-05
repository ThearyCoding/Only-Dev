import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class CustomDottedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const CustomDottedButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
       final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: onPressed,
      child: DottedBorder(
        color: color,
        strokeWidth: 1.0,
        dashPattern: const [4, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}