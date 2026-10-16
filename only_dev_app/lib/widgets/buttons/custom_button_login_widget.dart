import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String? imagePath;
  final Color? bgcolor;
  final Color? labelColor;
  final bool isLoading; 

  const CustomButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.imagePath,
    this.bgcolor,
    this.labelColor,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: bgcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
         
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Image.asset(
                    imagePath!,
                    height: 32,
                  ),
                if (imagePath != null) const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: labelColor,
                  ),
                ),
              ],
            ),
    );
  }
}
