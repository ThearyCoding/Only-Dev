import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:only_dev_app/data/repositories/storage_repository.dart';
import 'package:only_dev_app/data/repositories/user_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/global_navigation.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/features/auth/provider/auth_provider.dart';
import 'package:only_dev_app/service/api/dio_client.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = locator<FirebaseAuth>();
  final UserRepository _userRepository = locator<UserRepository>();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthenticationProvider? authProvider;

  UserModel? _userModel;
  UserModel? get userModel => _userModel ?? _user;

  UserProvider(this.authProvider) {
    _checkAuthState();
  }

  void setUserData(UserModel userModel) {
    _userModel = userModel;
    _user = userModel;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await _userRepository.getMyProfile();
      _user = profile;
      _userModel = profile;
    } catch (e) {
      log('Error fetching user profile from REST API: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? bio,
    String? phoneNumber,
    int? gender,
    String? dob,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final computedFullName = fullName ??
          (firstName != null && lastName != null
              ? '$firstName $lastName'.trim()
              : firstName ?? lastName);

      final updated = await _userRepository.updateProfile(
        fullName: computedFullName,
        avatarUrl: avatarUrl,
        headline: headline,
        bio: bio,
        phoneNumber: phoneNumber,
      );
      _user = updated;
      _userModel = updated;
      return updated;
    } catch (e) {
      log('Error updating user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      final storageRepo = locator<StorageRepository>();
      final downloadUrl = await storageRepo.uploadFile(imageFile, folder: 'user_images');
      await updateProfile(avatarUrl: downloadUrl);
      return downloadUrl;
    } catch (e) {
      log('Error uploading avatar: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkAuthState() async {
    final User? firebaseUser = _auth.currentUser;
    final token = locator<DioClient>().authInterceptor.token;
    final hasBackendToken = token != null && token.isNotEmpty;
    final context = navigatorKey.currentContext;

    if (firebaseUser != null || hasBackendToken) {
      try {
        await loadUserProfile();
      } catch (e) {
        log('Error in _checkAuthState: $e');
        if (context != null) {
          await handleUserLogout();
        }
      }
    } else {
      log('No user is currently signed in');
      _user = null;
      _userModel = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleUserLogout() async {
    final context = navigatorKey.currentContext;
    log('Handling user logout');
    if (authProvider != null) {
      await authProvider!.logoutUser();
    }
    await locator<DioClient>().authInterceptor.clearTokens();
    await _auth.signOut();
    _user = null;
    _userModel = null;
    notifyListeners();
    if (context != null && context.mounted) {
      context.go(RoutesPath.home);
    }
  }
}
