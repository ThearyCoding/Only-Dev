import 'dart:ui';

import 'package:flutter/material.dart';
import '../../export/export.dart';
import '../../widgets/background-widget/build_background_network.dart';

class LoginwithSocialMediaOrSignUpWithEmail extends StatefulWidget {
  const LoginwithSocialMediaOrSignUpWithEmail({super.key});

  @override
  State<LoginwithSocialMediaOrSignUpWithEmail> createState() => _LoginwithSocialMediaOrSignUpWithEmailState();
}

class _LoginwithSocialMediaOrSignUpWithEmailState extends State<LoginwithSocialMediaOrSignUpWithEmail> {
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
          // Animated Background
          const AnimatedBackground(),
          
          // Frosted Glass Effect with Blue Tint
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.blue.withOpacity(0.2),
                    BlendMode.modulate,
                  ),
                  child: Container(color: Colors.transparent), // Transparent container for applying the filter
                ),
              ),
            ),
          ),
          
          // PageView with Different Login Options
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
        ],
      ),
    );
  }
}