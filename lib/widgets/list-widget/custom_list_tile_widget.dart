import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomListTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final Widget? trailingIcon;
  final String? trailingText;
  final Function() onTap;

  const CustomListTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
    this.trailingIcon = const Icon(Icons.arrow_forward_ios, size: 14),
    this.trailingText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : const Color(0xffF6F6F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            leadingIcon,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText!,
                    style: const TextStyle(fontSize: 14),
                  ),
                if (trailingIcon != null) ...[
                  if (trailingText != null) const SizedBox(width: 8),
                  trailingIcon!,
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
