import 'dart:developer';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import '../../export/export.dart';

class MainLoginScreen extends StatelessWidget {
  final AuthServiceGoogle _authService = locator<AuthServiceGoogle>();
  final AuthServiceFacebook _authServiceFacebook = locator<AuthServiceFacebook>();
  final VoidCallback? onSwitchToSignUp;
  final VoidCallback? onSwitchToLogin;

  // Create a ValueNotifier to track the loading state.
  final ValueNotifier<bool> _isLoggingIn = ValueNotifier(false);

  MainLoginScreen({super.key, this.onSwitchToSignUp, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to App E-learning',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const CustomTextAnimationWidget(
                  texts: [
                    'Learn with Us',
                    'Grow Your Skills',
                    'Explore New Topics',
                    'Join the Community',
                    'Enhance Your Knowledge',
                    'Achieve Your Goals',
                  ],
                  textStyles: [
                    TextStyle(fontSize: 18, color: Colors.white),
                    TextStyle(fontSize: 18, color: Colors.green),
                    TextStyle(fontSize: 18, color: Colors.blue),
                    TextStyle(fontSize: 18, color: Colors.red),
                    TextStyle(fontSize: 18, color: Colors.orange),
                    TextStyle(fontSize: 18, color: Colors.purple),
                  ],
                  speed: Duration(milliseconds: 50),
                  repeatForever: true,
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Use ValueListenableBuilder to enable/disable the button
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoggingIn,
                        builder: (context, isLoggingIn, child) {
                          return CustomButtonWidget(
                            text: 'Continue with email',
                            bgcolor: const Color.fromARGB(157, 193, 193, 193),
                            labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                            onPressed: isLoggingIn
                                ? null
                                : () {
                                    if (onSwitchToLogin != null) {
                                      onSwitchToLogin!();
                                    }
                                  },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Or connect with',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Disable login buttons when logging in
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoggingIn,
                        builder: (context, isLoggingIn, child) {
                          return Column(
                            children: [
                              CustomButtonWidget(
                                bgcolor: Colors.white,
                                text: 'Login with Google',
                                onPressed: isLoggingIn ? null : () async {
                                  _isLoggingIn.value = true;
                                  try {
                                    final user = await _authService.signInWithGoogle();
                                    if (user != null) {
                                      log('Signed in as: ${user.displayName}');
                                    } else {
                                      log('Sign-in failed.');
                                    }
                                  } finally {
                                    _isLoggingIn.value = false;
                                  }
                                },
                                imagePath: 'assets/google-removebg-preview.png',
                              ),
                              const SizedBox(height: 20),
                              CustomButtonWidget(
                                labelColor: Colors.black87,
                                bgcolor: Colors.white,
                                text: 'Login with Facebook',
                                onPressed: isLoggingIn ? null : () async {
                                  _isLoggingIn.value = true;
                                  try {
                                    final user = await _authServiceFacebook.loginWithFacebook(context);
                                    if (user != null) {
                                      log('Signed in as: ${user.user!.displayName}');
                                    } else {
                                      log('Sign-in failed.');
                                    }
                                  } finally {
                                    _isLoggingIn.value = false;
                                  }
                                },
                                imagePath: 'assets/fb-removebg-preview.png',
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Create new account?',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            onPressed: onSwitchToSignUp ?? () {},
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 16),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
