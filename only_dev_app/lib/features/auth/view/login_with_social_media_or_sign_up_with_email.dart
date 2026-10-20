import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'login_view.dart';
import 'register_view.dart';

class LoginwithSocialMediaOrSignUpWithEmail extends StatefulWidget {
  final bool initialIsSignUp;

  const LoginwithSocialMediaOrSignUpWithEmail({
    super.key,
    this.initialIsSignUp = false,
  });

  @override
  State<LoginwithSocialMediaOrSignUpWithEmail> createState() =>
      _LoginwithSocialMediaOrSignUpWithEmailState();
}

class _LoginwithSocialMediaOrSignUpWithEmailState
    extends State<LoginwithSocialMediaOrSignUpWithEmail> {
  late bool _isLoginMode;

  @override
  void initState() {
    super.initState();
    _isLoginMode = !widget.initialIsSignUp;
  }

  void _switchToLogin() {
    setState(() => _isLoginMode = true);
  }

  void _switchToSignUp() {
    setState(() => _isLoginMode = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RoutesPath.home);
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  // Segmented Switcher Tab (No Animation)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabButton(
                          title: 'Sign In',
                          isActive: _isLoginMode,
                          onTap: _switchToLogin,
                          isDark: isDark,
                        ),
                        _buildTabButton(
                          title: 'Sign Up',
                          isActive: !_isLoginMode,
                          onTap: _switchToSignUp,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 38), // Balance spacing
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // App Brand Header
                    Container(
                      width: 56,
                      height: 56,
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
                          size: 30,
                          color: AppStyle.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Only Dev',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppStyle.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppStyle.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Active Form (Instant Switch, No Animation)
                    _isLoginMode
                        ? LoginView(onSwitchToSignUp: _switchToSignUp)
                        : RegisterView(onSwitchToLogin: _switchToLogin),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF262626) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? Colors.white54 : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}
