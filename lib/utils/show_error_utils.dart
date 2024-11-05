import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../export/export.dart';

enum CustomSnackPosition { top, bottom }

void showSnackbar(String message, {ToastGravity gravity = ToastGravity.TOP}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: gravity,
    backgroundColor: Colors.grey.shade800,
    textColor: Colors.white,
  );
}

void handleError(error, String message) {
  if (error is SocketException) {
    showSnackbar('No internet connection. Please check your network.');
  } else if (error is TimeoutException) {
    showSnackbar('Connection timed out. Please try again.');
  } else {
    showSnackbar(message);
  }
}

void showFriendlyErrorSnackbar(FirebaseException exception) {
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
    // Cloud Firestore specific errors
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
    // Firebase Storage specific errors
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
  showSnackbar(
    userFriendlyMessage,
  );
}
