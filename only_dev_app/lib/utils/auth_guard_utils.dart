import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/service/api/dio_client.dart';

class AuthGuard {
  /// Checks whether a user has an active session (JWT access token or Firebase auth).
  static bool isAuthenticated() {
    try {
      final token = locator.isRegistered<DioClient>()
          ? locator<DioClient>().authInterceptor.token
          : null;
      final firebaseUser = locator.isRegistered<FirebaseAuth>()
          ? locator<FirebaseAuth>().currentUser
          : null;
      return (token != null && token.isNotEmpty) || firebaseUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user to sign in if they are currently a guest.
  /// Returns `true` if already authenticated or if the user signs in successfully.
  /// Returns `false` if the user cancels or dismisses the prompt.
  static Future<bool> requireAuth(
    BuildContext context, {
    String? title,
    String? message,
    String? actionLabel,
  }) async {
    if (isAuthenticated()) {
      return true;
    }

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AuthPromptSheet(
        title: title ?? 'Sign In Required',
        message: message ??
            'Sign in to your Only Dev account to access this feature, track your learning progress, and save your enrollments.',
        actionLabel: actionLabel ?? 'Sign In / Register',
      ),
    );

    return isAuthenticated();
  }
}

class _AuthPromptSheet extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;

  const _AuthPromptSheet({
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Lock icon in gradient circle
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            // Sign In / Register button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await context.push(RoutesPath.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Not now / cancel
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

