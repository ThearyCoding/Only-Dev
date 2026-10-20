import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/routes/app_routes.dart';

class GoogleSignInButton extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const GoogleSignInButton({super.key, this.onSuccess});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = ref.read(authNotifierProvider);
      final user = await authProvider.signInWithGoogle();
      if (user != null) {
        log('Google Sign-in successful: ${user.email}');
        await authProvider.saveUserLoginStatus(true);
        if (mounted) {
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else if (context.canPop()) {
            context.pop(true);
          } else {
            context.go(RoutesPath.home);
          }
        }
      }
    } catch (e) {
      log('Google sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white,
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyle.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppStyle.primaryColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google-removebg-preview.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
