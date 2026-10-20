import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import '../app_widgets/app_image_widget.dart';
import 'package:only_dev_app/utils/generate_color.dart';

class ProfileImage extends ConsumerWidget {
  final VoidCallback onTap;

  const ProfileImage({super.key, required this.onTap});

  Color _resolveUserColor(String? rawColor) {
    if (rawColor != null && rawColor.trim().isNotEmpty) {
      final sanitized = rawColor.trim();
      final hex = sanitized.startsWith('#')
          ? '0xff${sanitized.substring(1)}'
          : (sanitized.startsWith('0x') ? sanitized : '0xff$sanitized');
      final parsed = int.tryParse(hex);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return GenerateColor.generateRandomColor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(userNotifierProvider);
    final user = provider.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final photoURL = user.photoURL.isNotEmpty
        ? user.photoURL
        : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
            ? user.avatarUrl!
            : null;

    // Extract initials from the user's name
    String initials = '';
    if (user.firstName.isNotEmpty) {
      initials += user.firstName[0];
    }
    if (user.lastName.isNotEmpty) {
      initials += user.lastName[0];
    }
    if (initials.isEmpty && user.fullName.isNotEmpty) {
      initials = user.fullName[0];
    }

    final userColor = _resolveUserColor(user.backgroundColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AppCircleAvatar(
            imageUrl: photoURL,
            name: user.fullName,
            radius: 20,
            backgroundColor: userColor,
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
