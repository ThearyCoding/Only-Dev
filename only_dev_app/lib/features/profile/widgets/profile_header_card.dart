import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onCameraTap;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onCameraTap,
  });

  Color _resolveUserColor(String? rawColor) {
    if (rawColor != null && rawColor.trim().isNotEmpty) {
      final sanitized = rawColor.trim();
      final hex = sanitized.startsWith('#')
          ? '0xff${sanitized.substring(1)}'
          : (rawColor.startsWith('0x') ? rawColor : '0xff$sanitized');
      final parsed = int.tryParse(hex);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final avatarUrl = user.photoURL.isNotEmpty
        ? user.photoURL
        : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
            ? user.avatarUrl!
            : null;

    final userBgColor = _resolveUserColor(user.backgroundColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          // Avatar Stack
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: GestureDetector(
                  onTap: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? () => context.push(
                            RoutesPath.detailImageScreen,
                            extra: {'imageUrl': avatarUrl},
                          )
                      : null,
                  child: AppCircleAvatar(
                    imageUrl: avatarUrl,
                    name: user.fullName,
                    radius: 46,
                    backgroundColor: userBgColor,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: ZoomTapAnimation(
                  onTap: onCameraTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Full Name & Role Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName
                      : '${user.firstName} ${user.lastName}'.trim(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildRolePill(user.role),
            ],
          ),
          const SizedBox(height: 4),

          // Email
          if (user.email.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  size: 14,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

          // Headline / Bio Pill
          const SizedBox(height: 12),
          ZoomTapAnimation(
            onTap: () => context.push(RoutesPath.editProfileInformation),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 14,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      (user.headline != null && user.headline!.isNotEmpty)
                          ? user.headline!
                          : (user.bio != null && user.bio!.isNotEmpty)
                              ? user.bio!
                              : 'Tap to add your developer headline & bio...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: (user.headline?.isNotEmpty == true || user.bio?.isNotEmpty == true)
                            ? (isDark ? Colors.white70 : Colors.black87)
                            : (isDark ? Colors.white38 : Colors.grey.shade500),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePill(String role) {
    Color bg;
    Color fg;
    IconData icon;

    switch (role.toUpperCase()) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.shield_rounded;
        break;
      case 'INSTRUCTOR':
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4338CA);
        icon = Icons.school_rounded;
        break;
      default:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        icon = Icons.code_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            role.isNotEmpty ? role.toUpperCase() : 'STUDENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

