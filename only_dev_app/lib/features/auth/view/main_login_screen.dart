import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/widgets/buttons/custom_button_login_widget.dart';
import 'package:only_dev_app/widgets/other-widget/custom_text_animation_widget.dart';

class MainLoginScreen extends ConsumerWidget {
  final VoidCallback? onSwitchToSignUp;
  final VoidCallback? onSwitchToLogin;

  final ValueNotifier<bool> _isLoggingIn = ValueNotifier(false);

  MainLoginScreen({super.key, this.onSwitchToSignUp, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Only Dev',
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
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoggingIn,
                        builder: (context, isLoggingIn, child) {
                          return CustomButtonWidget(
                            text: 'Continue with email',
                            bgcolor: Colors.blue,
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
                                    final authProvider = ref.read(authNotifierProvider);
                                    final user = await authProvider.signInWithGoogle();
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
