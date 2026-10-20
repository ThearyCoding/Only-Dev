import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/profile/widgets/profile_header_card.dart';
import 'package:only_dev_app/features/profile/widgets/profile_menu_group.dart';
import 'package:only_dev_app/features/profile/widgets/profile_menu_item.dart';
import 'package:only_dev_app/features/profile/widgets/profile_stats_card.dart';
import 'package:only_dev_app/features/settings/provider/language_provider.dart';
import 'package:only_dev_app/features/settings/provider/theme_provider.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/compress_image_util.dart';
import 'package:only_dev_app/utils/image_picker_utils.dart';
import 'package:only_dev_app/utils/show_dialog_sign_out_utils.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await ref.read(userProfileProvider.notifier).loadProfile();
      if (mounted) {
        final regProvider = ref.read(registrationNotifierProvider);
        await regProvider.init();
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    try {
      final File? croppedFile = await ImageUtils.pickImage();
      if (croppedFile != null) {
        final File? compressedImage =
            await CompressImageUtils.compressImage(croppedFile);
        if (compressedImage != null) {
          EasyLoading.show(status: 'Updating profile avatar...');
          await ref
              .read(userProfileProvider.notifier)
              .uploadAvatar(compressedImage);

          if (!mounted) return;
          final updatedUser = ref.read(userProfileProvider).user;
          if (updatedUser != null) {
            ref.read(userNotifierProvider).setUserData(updatedUser);
          }
          EasyLoading.showSuccess('Avatar updated successfully!');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (kDebugMode) {
        print('Error uploading avatar: $e');
      }
      EasyLoading.showError('Failed to upload avatar');
    }
  }

  Future<void> _handleLogout() async {
    final localization = AppLocalizations.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogOutDialog(
        title: localization.logout_title,
        message: localization.logout_message,
        icon: Icons.logout_rounded,
      ),
    );

    if (confirm == true && mounted) {
      EasyLoading.show(status: 'Signing out...');
      final userProvider = ref.read(userNotifierProvider);
      await userProvider.handleUserLogout();
      EasyLoading.dismiss();
    }
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : Theme.of(context).cardColor,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.code_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Only Dev',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 (Build 2026)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The developer-centric learning platform built for modern full-stack development, streaming video tutorials, and interactive coding quizzes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);

    final profileState = ref.watch(userProfileProvider);
    final userProviderState = ref.watch(userNotifierProvider);
    final regProvider = ref.watch(registrationNotifierProvider);
    final themeProvider = ref.watch(themeNotifierProvider);
    final languageProvider = ref.watch(languageNotifierProvider);

    final currentUser = profileState.user ?? userProviderState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          ThemeSwitcher(
            builder: (context) {
              return IconButton(
                tooltip: 'Toggle Theme',
                icon: Icon(
                  themeProvider.currentTheme == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : const Color(0xFF475569),
                  size: 22,
                ),
                onPressed: () {
                  themeProvider.switchTheme(context);
                },
              );
            },
          ),
          IconButton(
            tooltip: localization.editProfile,
            icon: const Icon(IconlyLight.edit, size: 20),
            onPressed: () {
              if (currentUser != null) {
                userProviderState.setUserData(currentUser);
              }
              context.push(RoutesPath.editProfileInformation);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: profileState.isLoading && currentUser == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : currentUser == null
                ? _buildEmptyState(isDark)
                : _buildProfileContent(
                    context,
                    user: currentUser,
                    isDark: isDark,
                    localization: localization,
                    enrolledCoursesCount: regProvider.registeredCourses.length,
                    themeProvider: themeProvider,
                    languageProvider: languageProvider,
                  ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_rounded,
                size: 64,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load profile information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context, {
    required UserModel user,
    required bool isDark,
    required AppLocalizations localization,
    required int enrolledCoursesCount,
    required CustomizeThemeProvider themeProvider,
    required LanguageProvider languageProvider,
  }) {
    final languageName = languageProvider.locale.languageCode == 'km'
        ? localization.khmer
        : localization.english;

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 1. Hero Header Card
        ProfileHeaderCard(
          user: user,
          onCameraTap: _pickImage,
        ),
        const SizedBox(height: 12),

        // 2. Stats Overview Card
        ProfileStatsCard(
          user: user,
          enrolledCoursesCount: enrolledCoursesCount,
        ),
        const SizedBox(height: 16),

        // 3. Learning & Account Section
        ProfileMenuGroup(
          title: localization.yourAccount,
          items: [
            ProfileMenuItem(
              icon: IconlyLight.profile,
              iconColor: const Color(0xFF3B82F6),
              title: localization.editProfile,
              subtitle: 'Update your name, headline and bio',
              onTap: () {
                ref.read(userNotifierProvider).setUserData(user);
                context.push(RoutesPath.editProfileInformation);
              },
            ),
            ProfileMenuItem(
              icon: Icons.video_library_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: localization.myCourses,
              subtitle: 'Access your enrolled courses and progress',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (enrolledCoursesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$enrolledCoursesCount active',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                ],
              ),
              onTap: () => context.push(RoutesPath.myCoursesScreen),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. Preferences Section
        ProfileMenuGroup(
          title: localization.appSettings,
          items: [
            ThemeSwitcher(
              builder: (context) {
                return ProfileMenuItem(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Dark Mode',
                  subtitle: isDark ? 'Dark theme enabled' : 'Light theme enabled',
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: const Color(0xFFF59E0B),
                    onChanged: (value) {
                      themeProvider.switchTheme(context);
                    },
                  ),
                  onTap: () {
                    themeProvider.switchTheme(context);
                  },
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.translate_rounded,
              iconColor: const Color(0xFF06B6D4),
              title: localization.chooseLanguage,
              subtitle: 'Selected: $languageName',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      languageProvider.locale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF06B6D4),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                ],
              ),
              onTap: () =>
                  context.pushNamed(RoutesPath.languageSelectionScreen),
            ),
            ProfileMenuItem(
              icon: Icons.notifications_none_rounded,
              iconColor: const Color(0xFFEC4899),
              title: localization.notifications,
              subtitle: 'Notification permissions and alerts',
              onTap: () => context.push(RoutesPath.isEnableNotifications),
            ),
            ProfileMenuItem(
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF64748B),
              title: localization.settings,
              subtitle: 'General application settings',
              onTap: () => context.push(RoutesPath.settingscreen),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 5. Support & Legal Section
        ProfileMenuGroup(
          title: 'Support & Legal',
          items: [
            ProfileMenuItem(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF6366F1),
              title: 'About Only Dev',
              subtitle: 'Version 1.0.0 (Build 2026)',
              onTap: () => _showAboutDialog(context, isDark),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 6. Logout Section
        ProfileMenuGroup(
          items: [
            ProfileMenuItem(
              icon: Icons.logout_rounded,
              iconColor: Colors.redAccent,
              title: localization.logOut,
              subtitle: 'Sign out from this device',
              isDestructive: true,
              onTap: _handleLogout,
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
