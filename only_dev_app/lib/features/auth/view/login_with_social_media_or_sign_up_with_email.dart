import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'login_with_email_screen.dart';
import 'main_login_screen.dart';
import 'sign_up_with_email_screen.dart';
import 'package:only_dev_app/widgets/background-widget/build_background_network.dart';

class LoginwithSocialMediaOrSignUpWithEmail extends StatefulWidget {
  const LoginwithSocialMediaOrSignUpWithEmail({super.key});

  @override
  State<LoginwithSocialMediaOrSignUpWithEmail> createState() =>
      _LoginwithSocialMediaOrSignUpWithEmailState();
}

class _LoginwithSocialMediaOrSignUpWithEmailState
    extends State<LoginwithSocialMediaOrSignUpWithEmail> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleToSignUp() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleToLoginWithEmail() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleToLoginScreen() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.blue.withValues(alpha: .2),
                    BlendMode.modulate,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MainLoginScreen(
                onSwitchToSignUp: _toggleToSignUp,
                onSwitchToLogin: _toggleToLoginWithEmail,
              ),
              SignUpWithEmailScreen(onSwitchToLogin: _toggleToLoginScreen),
              LoginWithEmailScreen(onSwitchToSignUp: _toggleToLoginScreen),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: IconButton(
                  tooltip: 'Close',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RoutesPath.home);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
