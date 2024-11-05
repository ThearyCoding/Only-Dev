import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color? labelColor;
  final Color? bgColor;
  final Color? borderColor;
  final double borderWidth;
  final double width;
  final double height;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.labelColor,
    this.bgColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.width = double.infinity,
    this.height = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    
    // Determine colors based on theme and provided parameters
    Color currentLabelColor = labelColor ?? theme.textTheme.bodyLarge!.color!;
    Color currentBgColor = bgColor ?? theme.primaryColor;
    Color currentBorderColor = borderColor ?? theme.primaryColor;

    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: currentBorderColor, width: borderWidth),
          ),
          backgroundColor: currentBgColor,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        child: Text(
          label,
          style: TextStyle(color: currentLabelColor, fontSize: 16),
        ),
      ),
    );
  }
}
