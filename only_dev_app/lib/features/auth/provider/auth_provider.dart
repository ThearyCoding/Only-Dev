
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/service/firebase/auth_service_google.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';

class AuthenticationProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  final FirebaseAuth? _customAuth;
  final AuthServiceGoogle? _customGoogleAuth;

  FirebaseAuth get _auth =>
      _customAuth ??
      (locator.isRegistered<FirebaseAuth>()
          ? locator<FirebaseAuth>()
          : FirebaseAuth.instance);

  AuthServiceGoogle get _authServiceGoogle =>
      _customGoogleAuth ??
      (locator.isRegistered<AuthServiceGoogle>()
          ? locator<AuthServiceGoogle>()
          : AuthServiceGoogle());

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  AuthenticationProvider({
    FirebaseAuth? auth,
    AuthServiceGoogle? authServiceGoogle,
  })  : _customAuth = auth,
        _customGoogleAuth = authServiceGoogle {
    loadUserLoginStatus();
  }

  Future<void> saveUserLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    _isLoggedIn = isLoggedIn;
    notifyListeners();
  }

  Future<void> loadUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    _isLoggedIn = false;
    notifyListeners();
  }

  final Map<String, String> _errorMessages = {
    "email-already-in-use":
        'This email is already registered. Please use another email or log in.',
    "weak-password": 'The password provided is too weak.',
    "invalid-email": 'The email address is not valid.',
    "operation-not-allowed":
        'Signing up with email and password is not enabled.',
    "user-disabled": 'This user has been disabled.',
    "user-not-found": 'No user found for that email.',
    "wrong-password": 'Wrong password provided.',
    "too-many-requests": 'Too many requests. Try again later.',
    "account-exists-with-different-credential":
        'An account already exists with the same email but different sign-in credentials. Use a different method to sign in.',
    "invalid-credential": 'The provided credentials are invalid.',
  };

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      AppToastUtils.success('Account created successfully!');
    } catch (e) {
      if (e is FirebaseAuthException) {
        String userFriendlyMessage =
            _errorMessages[e.code] ?? 'Failed to create account: ${e.message}';
        AppToastUtils.error(userFriendlyMessage);
      } else {
        AppToastUtils.error('Failed to create account. Please try again.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      AppToastUtils.success('Logged in successfully!');
    } catch (e) {
      if (e is FirebaseAuthException) {
        String userFriendlyMessage =
            _errorMessages[e.code] ?? 'Failed to log in: ${e.message}';
        AppToastUtils.error(userFriendlyMessage);
      } else {
        AppToastUtils.error('Failed to log in. Please try again.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authServiceGoogle.signInWithGoogle();
      if (user != null) {
        await saveUserLoginStatus(true);
      }
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSignedInWithGoogle(User? user) {
    if (user == null) return false;
    return _authServiceGoogle.isSignedInWithGoogle(user);
  }
}
