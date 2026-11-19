import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/courses/view/course_list_screen.dart';
import 'package:only_dev_app/features/notifications/view/notification_screen.dart';
import 'package:only_dev_app/features/profile/view/user_information_screen.dart';
import 'package:only_dev_app/features/search/view/search_page.dart';
import 'package:only_dev_app/widgets/navigation/liquid_glass_nav_bar.dart';
import 'home_screen.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  static const int _notificationsIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final unreadCount =
        ref.watch(notificationNotifierProvider).unreadCount.value;

    return Scaffold(
      // Let page content scroll behind the floating glass bar.
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomePage(),
          CourseListScreen(),
          NotificationsScreen(),
          UserInformationScreen(),
        ],
      ),
      bottomNavigationBar: LiquidGlassNavBar(
        currentIndex: selectedIndex,
        activeColor: AppStyle.primaryColor,
        items: [
          const LiquidGlassNavItem(
            label: 'Home',
            icon: CupertinoIcons.house,
            activeIcon: CupertinoIcons.house_fill,
          ),
          const LiquidGlassNavItem(
            label: 'Courses',
            icon: CupertinoIcons.play_rectangle,
            activeIcon: CupertinoIcons.play_rectangle_fill,
          ),
          LiquidGlassNavItem(
            label: 'Alerts',
            icon: CupertinoIcons.bell,
            activeIcon: CupertinoIcons.bell_fill,
            badgeCount: unreadCount,
          ),
          const LiquidGlassNavItem(
            label: 'Profile',
            icon: CupertinoIcons.person,
            activeIcon: CupertinoIcons.person_fill,
          ),
        ],
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          if (index == _notificationsIndex) {
            ref.read(notificationNotifierProvider).markAllAsRead();
          }
        },
        trailingIcon: CupertinoIcons.search,
        trailingTooltip: 'Search',
        onTrailingTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        ),
      ),
    );
  }
}
