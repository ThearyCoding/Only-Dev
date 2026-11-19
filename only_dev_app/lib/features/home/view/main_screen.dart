import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/courses/view/course_list_screen.dart';
import 'package:only_dev_app/features/notifications/view/notification_screen.dart';
import 'package:only_dev_app/features/profile/view/user_information_screen.dart';
import 'home_screen.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomePage(),
          CourseListScreen(),
          NotificationsScreen(),
          UserInformationScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppStyle.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 0,
                  label: 'Home',
                  inactiveIcon: IconlyLight.home,
                  activeIcon: IconlyBold.home,
                  selectedIndex: selectedIndex,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 1,
                  label: 'Courses',
                  inactiveIcon: Icons.video_collection_outlined,
                  activeIcon: Icons.video_collection,
                  selectedIndex: selectedIndex,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 2,
                  label: 'Alerts',
                  inactiveIcon: IconlyLight.notification,
                  activeIcon: IconlyBold.notification,
                  selectedIndex: selectedIndex,
                  isNotification: true,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 3,
                  label: 'Profile',
                  inactiveIcon: IconlyLight.profile,
                  activeIcon: IconlyBold.profile,
                  selectedIndex: selectedIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required String label,
    required IconData inactiveIcon,
    required IconData activeIcon,
    required int selectedIndex,
    bool isNotification = false,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(bottomNavIndexProvider.notifier).state = index;
            if (isNotification) {
              ref.read(notificationNotifierProvider).markAllAsRead();
            }
          },
          splashColor: AppStyle.primaryColor.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppStyle.primaryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? activeIcon : inactiveIcon,
                      size: 22,
                      color: isSelected
                          ? AppStyle.primaryColor
                          : Colors.grey.shade500,
                    ),
                    if (isNotification)
                      Consumer(
                        builder: (context, ref, child) {
                          final notif = ref.watch(notificationNotifierProvider);
                          final count = notif.unreadCount.value;
                          if (count <= 0) return const SizedBox.shrink();
                          return Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppStyle.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppStyle.primaryColor
                      : Colors.grey.shade500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
