
import '../di/dependency_injection.dart';
import '../export/export.dart';
import '../utils/show_error_utils.dart';

class AuthenticationProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  final FirebaseAuth _auth = locator<FirebaseAuth>();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthenticationProvider() {
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
      showSnackbar('Account created successfully!',
);
    } catch (e) {
      if (e is FirebaseAuthException) {
        String userFriendlyMessage =
            _errorMessages[e.code] ?? 'Failed to create account: ${e.message}';
        showSnackbar(userFriendlyMessage);
      } else {
        showSnackbar('Failed to create account. Please try again.');
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
      showSnackbar('Logged in successfully!',);
    } catch (e) {
      if (e is FirebaseAuthException) {
        String userFriendlyMessage =
            _errorMessages[e.code] ?? 'Failed to log in: ${e.message}';
        showSnackbar(userFriendlyMessage);
      } else {
        showSnackbar('Failed to log in. Please try again.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
