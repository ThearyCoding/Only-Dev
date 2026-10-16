import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toastify_flutter/toastify_flutter.dart';
import '../core/global_navigation.dart';

/// A unified toast utility class powered by `toastify_flutter`.
///
/// Can be invoked with or without an explicit [BuildContext].
/// When [context] is omitted, it automatically uses `navigatorKey.currentContext`.
class AppToastUtils {
  AppToastUtils._();

  /// Resolves a high-contrast text style to guarantee visibility across light & dark app themes.
  static TextStyle _resolveTextStyle({
    required ToastStyle style,
    required ToastType type,
    TextStyle? customStyle,
  }) {
    if (customStyle != null && customStyle.color != null) {
      return customStyle;
    }

    // Determine readable text color based on toast background style
    final Color defaultColor;
    if (style == ToastStyle.fillColored) {
      // Vibrant filled backgrounds: white text (or dark for yellow warning)
      defaultColor = (type == ToastType.warning) ? const Color(0xFF1E293B) : Colors.white;
    } else {
      // Flat, simple, minimal, and flatColored styles have white or light pastel backgrounds
      defaultColor = const Color(0xFF1E293B);
    }

    return TextStyle(
      color: defaultColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ).merge(customStyle);
  }

  /// Displays a success toast notification.
  static void success(
    String message, {
    BuildContext? context,
    int duration = 3,
    ToastPosition position = ToastPosition.top,
    ToastStyle style = ToastStyle.flat,
    ToastAlignment alignment = ToastAlignment.center,
    TextStyle? textStyle,
    TextAlign textAlign = TextAlign.left,
    bool onClose = true,
    Curve animationCurve = Curves.easeInOut,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    final resolvedTextStyle = _resolveTextStyle(
      style: style,
      type: ToastType.success,
      customStyle: textStyle,
    );

    ToastifyFlutter.success(
      ctx,
      message: message,
      duration: duration,
      position: position,
      style: style,
      alignment: alignment,
      textStyle: resolvedTextStyle,
      textAlign: textAlign,
      onClose: onClose,
      animationCurve: animationCurve,
    );
  }

  /// Displays an error toast notification.
  static void error(
    String message, {
    BuildContext? context,
    int duration = 3,
    ToastPosition position = ToastPosition.top,
    ToastStyle style = ToastStyle.flat,
    ToastAlignment alignment = ToastAlignment.center,
    TextStyle? textStyle,
    TextAlign textAlign = TextAlign.left,
    bool onClose = true,
    Curve animationCurve = Curves.easeInOut,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    final resolvedTextStyle = _resolveTextStyle(
      style: style,
      type: ToastType.error,
      customStyle: textStyle,
    );

    ToastifyFlutter.error(
      ctx,
      message: message,
      duration: duration,
      position: position,
      style: style,
      alignment: alignment,
      textStyle: resolvedTextStyle,
      textAlign: textAlign,
      onClose: onClose,
      animationCurve: animationCurve,
    );
  }

  /// Displays a warning toast notification.
  static void warning(
    String message, {
    BuildContext? context,
    int duration = 3,
    ToastPosition position = ToastPosition.top,
    ToastStyle style = ToastStyle.flat,
    ToastAlignment alignment = ToastAlignment.center,
    TextStyle? textStyle,
    TextAlign textAlign = TextAlign.left,
    bool onClose = true,
    Curve animationCurve = Curves.easeInOut,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    final resolvedTextStyle = _resolveTextStyle(
      style: style,
      type: ToastType.warning,
      customStyle: textStyle,
    );

    ToastifyFlutter.warning(
      ctx,
      message: message,
      duration: duration,
      position: position,
      style: style,
      alignment: alignment,
      textStyle: resolvedTextStyle,
      textAlign: textAlign,
      onClose: onClose,
      animationCurve: animationCurve,
    );
  }

  /// Displays an informational toast notification.
  static void info(
    String message, {
    BuildContext? context,
    int duration = 3,
    ToastPosition position = ToastPosition.top,
    ToastStyle style = ToastStyle.flat,
    ToastAlignment alignment = ToastAlignment.center,
    TextStyle? textStyle,
    TextAlign textAlign = TextAlign.left,
    bool onClose = true,
    Curve animationCurve = Curves.easeInOut,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    final resolvedTextStyle = _resolveTextStyle(
      style: style,
      type: ToastType.info,
      customStyle: textStyle,
    );

    ToastifyFlutter.info(
      ctx,
      message: message,
      duration: duration,
      position: position,
      style: style,
      alignment: alignment,
      textStyle: resolvedTextStyle,
      textAlign: textAlign,
      onClose: onClose,
      animationCurve: animationCurve,
    );
  }

  /// Displays a toast notification with smart classification based on message keywords and icon.
  static void show(
    String message, {
    BuildContext? context,
    IconData? icon,
    Color? backgroundColor,
    bool showAtTop = true,
    int duration = 3,
    ToastStyle style = ToastStyle.flat,
  }) {
    final lower = message.toLowerCase();
    final isSuccess = lower.contains('success') ||
        lower.contains('completed') ||
        lower.contains('restored') ||
        lower.contains('enrolled') ||
        icon == Icons.check;
    final isError = lower.contains('error') ||
        lower.contains('failed') ||
        lower.contains('fail') ||
        lower.contains('lost') ||
        lower.contains('exception') ||
        lower.contains('not found');
    final isWarning = lower.contains('warning') ||
        lower.contains('already') ||
        lower.contains('requires') ||
        lower.contains('shortly') ||
        lower.contains('no more');

    final pos = showAtTop ? ToastPosition.top : ToastPosition.bottom;

    if (isSuccess) {
      success(
        message,
        context: context,
        duration: duration,
        position: pos,
        style: style,
      );
    } else if (isError) {
      error(
        message,
        context: context,
        duration: duration,
        position: pos,
        style: style,
      );
    } else if (isWarning) {
      warning(
        message,
        context: context,
        duration: duration,
        position: pos,
        style: style,
      );
    } else {
      info(
        message,
        context: context,
        duration: duration,
        position: pos,
        style: style,
      );
    }
  }

  /// Handles common network and general exceptions.
  static void handleError(dynamic error, String message) {
    if (error is SocketException) {
      AppToastUtils.error('No internet connection. Please check your network.');
    } else if (error is TimeoutException) {
      AppToastUtils.error('Connection timed out. Please try again.');
    } else {
      AppToastUtils.error(message);
    }
  }

  /// Displays a user-friendly toast message for Firebase exceptions.
  static void showFirebaseError(FirebaseException exception) {
    String userFriendlyMessage;

    switch (exception.code) {
      case 'account-exists-with-different-credential':
        userFriendlyMessage =
            'An account already exists with a different credential.';
        break;
      case 'invalid-email':
        userFriendlyMessage = 'The email address is not valid.';
        break;
      case 'user-not-found':
        userFriendlyMessage = 'No user found with this email.';
        break;
      case 'wrong-password':
        userFriendlyMessage = 'The password is incorrect.';
        break;
      case 'user-disabled':
        userFriendlyMessage = 'The user has been disabled.';
        break;
      case 'too-many-requests':
        userFriendlyMessage = 'Too many requests. Please try again later.';
        break;
      case 'operation-not-allowed':
        userFriendlyMessage = 'This operation is not allowed.';
        break;
      case 'no-internet':
        userFriendlyMessage =
            'No internet connection. Please check your network settings.';
        break;
      case 'requires-internet':
        userFriendlyMessage =
            'This action requires an internet connection. Please connect to the internet and try again.';
        break;
      case 'permission-denied':
        userFriendlyMessage =
            'You do not have permission to access this resource.';
        break;
      case 'unavailable':
        userFriendlyMessage =
            'The service is currently unavailable. Please try again later.';
        break;
      case 'deadline-exceeded':
        userFriendlyMessage =
            'The operation took too long to complete. Please try again later.';
        break;
      case 'not-found':
        userFriendlyMessage = 'The requested resource was not found.';
        break;
      case 'object-not-found':
        userFriendlyMessage = 'No object exists at the desired reference.';
        break;
      case 'bucket-not-found':
        userFriendlyMessage = 'No bucket is configured for Cloud Storage.';
        break;
      case 'project-not-found':
        userFriendlyMessage = 'No project is configured for Cloud Storage.';
        break;
      case 'quota-exceeded':
        userFriendlyMessage =
            'Quota on your Cloud Storage bucket has been exceeded.';
        break;
      case 'unauthenticated':
        userFriendlyMessage =
            'User is unauthenticated. Please authenticate and try again.';
        break;
      case 'unauthorized':
        userFriendlyMessage =
            'User is not authorized to perform the desired action.';
        break;
      case 'retry-limit-exceeded':
        userFriendlyMessage =
            'The maximum time limit on an operation (upload, download, delete, etc.) has been exceeded. Try again.';
        break;
      case 'invalid-checksum':
        userFriendlyMessage =
            'File on the client does not match the checksum of the file received by the server. Try uploading again.';
        break;
      case 'canceled':
        userFriendlyMessage = 'The operation was canceled.';
        break;
      default:
        userFriendlyMessage =
            'An unexpected error occurred: ${exception.message ?? 'Unknown error'}';
        break;
    }
    AppToastUtils.error(userFriendlyMessage);
  }

  /// Closes the currently displayed toast, if any.
  static void close() {
    ToastifyFlutter.close();
  }
}
