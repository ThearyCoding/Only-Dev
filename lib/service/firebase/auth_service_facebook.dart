import 'dart:developer';

import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';

class AuthServiceFacebook {
  Future<UserCredential?> loginWithFacebook(BuildContext context) async {
    try {
      EasyLoading.show();
      // Trigger Facebook sign in
      final LoginResult result = await FacebookAuth.instance.login();

      if (result == null) {
        // User canceled the sign-in process
        EasyLoading.dismiss();
        return null;
      }
      // Check if Facebook sign in was successful
      if (result.status == LoginStatus.success) {
        // Retrieve Facebook access token
        final AccessToken accessToken = result.accessToken!;

        // Convert Facebook access token to AuthCredential
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        // Sign in with Facebook credential
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        EasyLoading.dismiss();
        // Return the signed-in user credential
        return userCredential;
      } else {
        // Facebook sign in failed
        log("Facebook sign in failed: ${result.status}");
        return null;
      }
    } catch (error) {
      if (error is FirebaseAuthException) {
        showFriendlyErrorSnackbar(error);
      } else {
        log("Error signing in with facebook: $error");
        showSnackbar(
           'An error occurred while signing in with Facebook.');
      }
      return null;
    } finally {
      EasyLoading.dismiss();
    }
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
