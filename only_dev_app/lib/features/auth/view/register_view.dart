import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/buttons/custom_btn_loading_widget.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterView extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToLogin;

  const RegisterView({super.key, this.onSwitchToLogin});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseView<AuthViewModel>(
      builder: (context, model, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start your journey with practical, production-ready courses.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              AuthTextField(
                controller: _fullNameController,
                labelText: 'Full Name',
                hintText: 'John Doe',
                prefixIcon: Icons.person_outline_rounded,
                validator: (input) {
                  if (input == null || input.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email
              AuthTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'name@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (input) {
                  if (input == null || input.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!input.contains('@') || !input.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Password
              AuthTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Minimum 6 characters',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (input.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password
              AuthTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (input != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Error display
              if (model.hasError && model.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyle.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                    border: Border.all(
                      color: AppStyle.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppStyle.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          model.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppStyle.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Create Account CTA Button
              CustomBtnLoadingWidget(
                btnText: 'Create Account',
                backgroundColor: AppStyle.primaryColor,
                borderRadius: AppStyle.radiusMd,
                onTap: (startLoading, stopLoading, btnState) async {
                  if (_formKey.currentState!.validate()) {
                    startLoading();
                    final success = await model.register(
                      email: _emailController.text,
                      password: _passwordController.text,
                      fullName: _fullNameController.text,
                    );
                    stopLoading();

                    if (success && context.mounted) {
                      if (model.currentUser != null) {
                        ref
                            .read(userNotifierProvider)
                            .setUserData(model.currentUser!);
                      }
                      await ref
                          .read(authNotifierProvider)
                          .saveUserLoginStatus(true);
                      if (context.mounted) {
                        if (context.canPop()) {
                          context.pop(true);
                        } else {
                          context.go(RoutesPath.home);
                        }
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 18),

              // Or divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Google Sign-In Button
              const GoogleSignInButton(),
              const SizedBox(height: 16),

              // Switch to Sign In link
              if (widget.onSwitchToLogin != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSwitchToLogin,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppStyle.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
