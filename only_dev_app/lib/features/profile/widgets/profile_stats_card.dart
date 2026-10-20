import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileStatsCard extends StatelessWidget {
  final UserModel user;
  final int enrolledCoursesCount;

  const ProfileStatsCard({
    super.key,
    required this.user,
    required this.enrolledCoursesCount,
  });

  String _formatJoinDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '2026';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return '${parsed.year}';
      }
    } catch (_) {}
    return '2026';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ZoomTapAnimation(
              onTap: () => context.push(RoutesPath.myCoursesScreen),
              child: _buildStatItem(
                context,
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF3B82F6),
                value: '$enrolledCoursesCount',
                label: 'Courses',
                isDark: isDark,
              ),
            ),
          ),
          _buildVerticalDivider(isDark),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.workspace_premium_rounded,
              iconColor: const Color(0xFFF59E0B),
              value: user.role.isNotEmpty ? user.role : 'Student',
              label: 'Role',
              isDark: isDark,
            ),
          ),
          _buildVerticalDivider(isDark),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.event_available_rounded,
              iconColor: const Color(0xFF10B981),
              value: _formatJoinDate(user.createdAt),
              label: 'Joined',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 36,
      width: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

