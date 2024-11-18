import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/global_navigation.dart';

FToast? fToast;

void showCustomToast({
  required String title,
  IconData? icon,
  Color? backgroundColor,
  bool showAtTop = false,
}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  

  // Initialize FToast if it hasn't been initialized yet
  fToast ??= FToast();
  fToast!.init(context);

  // Set default background color if null
  final toastBackgroundColor = backgroundColor ?? Colors.grey.shade800;

  // Define the custom toast widget with dynamic parameters
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: toastBackgroundColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, color: Colors.white),
        if (icon != null) const SizedBox(width: 12.0),
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  // Display toast based on the showAtTop parameter
  fToast!.showToast(
    child: toast,
    gravity: showAtTop ? ToastGravity.TOP : ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
}
