import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../utils/show_error_utils.dart';

class AuthServiceGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle() async {
    try {
      EasyLoading.show();

      // Sign out the current user if any
      await _googleSignIn.signOut();

      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      // User canceled the sign-in process
      if (googleSignInAccount == null) {
        log('User cancel logged in.');
        EasyLoading.dismiss();
        return null;
      }

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      return authResult.user;
    }on FirebaseException catch (error) {
      EasyLoading.dismiss();
      if (error is FirebaseAuthException) {
        showFriendlyErrorSnackbar(error);
      } else {
        log("Error signing in with Google: $error");
        showSnackbar(
          'An error occurred while signing in with Google.');
      }
      

      return null;
    } finally {
      EasyLoading.dismiss();
    }
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
