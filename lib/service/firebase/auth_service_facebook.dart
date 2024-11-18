import 'dart:developer';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';

class AuthServiceFacebook {
  Future<UserCredential?> loginWithFacebook(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Signing in with Facebook...');

      // Trigger Facebook sign-in
      final LoginResult result = await locator<FacebookAuth>().login();

      if (result.status == LoginStatus.cancelled) {
        // User canceled the sign-in process
        EasyLoading.dismiss();
        log('User canceled Facebook sign-in.');
        return null;
      } else if (result.status == LoginStatus.failed) {
        // Facebook sign-in failed
        EasyLoading.dismiss();
        log('Facebook sign-in failed: ${result.message}');
        showSnackbar('Facebook sign-in failed. Please try again.');
        return null;
      }

      // Check if Facebook sign-in was successful
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Convert Facebook access token to Firebase credential
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        // Sign in with the Facebook credential on Firebase
        UserCredential userCredential =
            await locator<FirebaseAuth>().signInWithCredential(credential);
        

        // Sign-in successful
        EasyLoading.dismiss();
        return userCredential;
      }

      return null;
    } on FirebaseAuthException catch (error) {
      // Handle Firebase-specific sign-in errors
      EasyLoading.dismiss();
      showFriendlyErrorSnackbar(error);
      log("FirebaseAuthException: ${error.message}");
    } on PlatformException catch (error) {
      // Handle platform-specific errors
      EasyLoading.dismiss();
      log("PlatformException: ${error.message}");
      showSnackbar('A network error occurred. Please try again.');
    } catch (error) {
      EasyLoading.dismiss();
      log("Unexpected error: $error");
      showSnackbar('An error occurred while signing in with Facebook.');
    } finally {
      EasyLoading.dismiss();
    }
    return null;
  }

  bool isSignedInWithFacebook(User user) {
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'facebook.com') {
        return true;
      }
    }
    return false;
  }
}
