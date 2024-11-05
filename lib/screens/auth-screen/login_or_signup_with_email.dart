import 'package:e_leaningapp/screens/auth-screen/login_with_email_screen.dart';
import 'package:e_leaningapp/screens/auth-screen/sign_up_with_email_screen.dart';
import 'package:flutter/cupertino.dart';

class LoginOrSignupWithEmail extends StatefulWidget {
  const LoginOrSignupWithEmail({super.key});

  @override
  State<LoginOrSignupWithEmail> createState() => _LoginOrSignupWithEmailState();
}

class _LoginOrSignupWithEmailState extends State<LoginOrSignupWithEmail> {
 bool _showLoginPage = true;

  void _togglePage() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLoginPage
        ? LoginWithEmailScreen(onSwitchToSignUp: _togglePage)
        : SignUpWithEmailScreen(onSwitchToLogin: _togglePage);
  }
}