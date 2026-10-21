import 'package:dot_navigation_bar/dot_navigation_bar.dart';
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

  Widget _buildIcon(IconData icon, bool isSelected, {int? badgeCount}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppStyle.primaryColor.withValues(alpha: .18)
                : Colors.transparent,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isSelected ? AppStyle.primaryColor : Colors.grey,
          ),
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            right: 0,
            top: 10,
            child: Badge(
              label: Text(
                badgeCount > 9 ? "9+" : badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: Colors.red,
              isLabelVisible: badgeCount != 0,
              child: Container(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
      bottomNavigationBar: DotNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          if (index == 2) {
            ref.read(notificationNotifierProvider).markAllAsRead();
          }
        },
        marginR: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        items: [
          DotNavigationBarItem(
            icon: _buildIcon(IconlyBold.home, selectedIndex == 0),
          ),
          DotNavigationBarItem(
            icon: _buildIcon(Icons.video_collection, selectedIndex == 1),
          ),
          DotNavigationBarItem(
            icon: Consumer(
              builder: (context, ref, child) {
                final notif = ref.watch(notificationNotifierProvider);
                return _buildIcon(
                  IconlyBold.notification,
                  selectedIndex == 2,
                  badgeCount: notif.unreadCount.value,
                );
              },
            ),
          ),
          DotNavigationBarItem(
            icon: _buildIcon(IconlyBold.profile, selectedIndex == 3),
          ),
        ],
        dotIndicatorColor: AppStyle.primaryColor,
        backgroundColor:
            isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        enablePaddingAnimation: false,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        paddingR: const EdgeInsets.all(8),
        selectedItemColor: AppStyle.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
