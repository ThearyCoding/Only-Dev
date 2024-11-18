import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/global_navigation.dart';
import '../model/user_model.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = locator<FirebaseAuth>();
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  AuthenticationProvider? authProvider;

  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  UserProvider(this.authProvider) {
    _checkAuthState();
  }

  void setUserData(UserModel userModel) {
    _userModel = userModel;
    notifyListeners();
  }

  Future<void> _checkAuthState() async {
    User? firebaseUser = _auth.currentUser;
    final context = navigatorKey.currentContext;
    if (firebaseUser != null) {
      String uid = firebaseUser.uid;
      try {
        _isLoading = true;
        notifyListeners();

        DocumentReference userRef = _firestore.collection('users').doc(uid);

        // Start listening to changes in the user's document
        _userDocSubscription = userRef.snapshots().listen((userDoc) async {
          if (userDoc.exists) {
            _user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          } else {
            // If the user document is deleted, log out the user
            if (context != null) {
              await handleUserLogout();
            }
          }
          _isLoading = false;
          notifyListeners();
        });
      } catch (e) {
        log('Error fetching user from Firestore: $e');
        if (context != null) {
          await handleUserLogout();
        }
      }
    } else {
      log('No user is currently signed in');
      _user = null;
      _isLoading = false;
      notifyListeners();

      if (context != null) {
        context.go('/');
      }
    }
  }

  @override
  dispose() {
    _userDocSubscription!.cancel();
    super.dispose();
  }

  Future<void> handleUserLogout() async {
    final context = navigatorKey.currentContext;
    log('Handling user logout');
    await authProvider!.logoutUser();
    await _auth.signOut();
    if (context != null) {
      if (!context.mounted) return;
      context.go('/');
    }
  }
}
