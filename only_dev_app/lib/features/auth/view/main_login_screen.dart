import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/buttons/custom_button_login_widget.dart';

class MainLoginScreen extends ConsumerWidget {
  final VoidCallback? onSwitchToSignUp;
  final VoidCallback? onSwitchToLogin;

  final ValueNotifier<bool> _isLoggingIn = ValueNotifier(false);

  MainLoginScreen({super.key, this.onSwitchToSignUp, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppStyle.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppStyle.primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.terminal_rounded,
                      size: 34,
                      color: AppStyle.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Only Dev',
                  style: TextStyle(
                    fontSize: 26,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Master software development with production projects.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoggingIn,
                        builder: (context, isLoggingIn, child) {
                          return CustomButtonWidget(
                            text: 'Continue with email',
                            bgcolor: AppStyle.primaryColor,
                            labelColor: Colors.white,
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
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Or connect with',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
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
                                bgcolor: isDark ? Colors.grey.shade900 : Colors.white,
                                labelColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                text: 'Login with Google',
                                onPressed: isLoggingIn ? null : () async {
                                  _isLoggingIn.value = true;
                                  try {
                                    final authProvider = ref.read(authNotifierProvider);
                                    final user = await authProvider.signInWithGoogle();
                                    if (user != null) {
                                      log('Signed in as: ${user.displayName}');
                                      await authProvider.saveUserLoginStatus(true);
                                      if (context.mounted) {
                                        if (context.canPop()) {
                                          context.pop(true);
                                        } else {
                                          context.go(RoutesPath.home);
                                        }
                                      }
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
                          Text(
                            'Create new account?',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: onSwitchToSignUp ?? () {},
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: AppStyle.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
