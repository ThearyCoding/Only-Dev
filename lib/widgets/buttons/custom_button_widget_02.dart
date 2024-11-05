import 'package:flutter/material.dart';

class CustomElevatedButtonWidget02 extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final bool isLoading;

  const CustomElevatedButtonWidget02({
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    required this.textColor,
    this.padding = const EdgeInsets.all(12.0),
    this.borderRadius = 8.0,
    this.borderColor,
    this.borderWidth,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        padding: WidgetStateProperty.all(padding),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null && borderWidth != null
                ? BorderSide(color: borderColor!, width: borderWidth!)
                : BorderSide.none,
          ),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 24.0,
              width: 24.0,
              child: CircularProgressIndicator(
                color: textColor,
                strokeWidth: 2.0,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: textColor,
              ),
            ),
    );
  }
}
