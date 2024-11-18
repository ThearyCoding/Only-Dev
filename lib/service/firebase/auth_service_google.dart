import 'dart:developer';
import '../../di/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../utils/show_error_utils.dart';

class AuthServiceGoogle {
  final FirebaseAuth _auth = locator<FirebaseAuth>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle() async {
    try {
      EasyLoading.show();
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        log('User canceled sign-in.');
        EasyLoading.dismiss();
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      return authResult.user;
    } on PlatformException catch (error) {
      EasyLoading.dismiss();
      log("PlatformException occurred: ${error.message}");
      showSnackbar('A network error occurred. Please try again.');
    } on FirebaseAuthException catch (error) {
      EasyLoading.dismiss();
      showFriendlyErrorSnackbar(error);
    } finally {
      EasyLoading.dismiss();
    }
    return null;
  }

  bool isSignedInWithGoogle(User user) {
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }
}
