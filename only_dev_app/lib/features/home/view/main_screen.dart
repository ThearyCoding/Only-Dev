import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:only_dev_app/core/app_style.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/courses/view/course_list_screen.dart';
import 'package:only_dev_app/features/notifications/view/notification_screen.dart';
import 'package:only_dev_app/features/profile/view/user_information_screen.dart';
import 'home_screen.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => MainPageState();
}

class MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        ref.read(notificationNotifierProvider).markAllAsRead();
      }
    });
  }

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

  void _onProfileImageTapped() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  void _onSeeAllCourses() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onNotificationTapped() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ThemeSwitchingArea(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomePage(
              onSeeAllCoursesTapped: _onSeeAllCourses,
              onProfileImageTapped: _onProfileImageTapped,
              onNotificationsTapped: _onNotificationTapped,
            ),
            const CourseListScreen(),
            const NotificationsScreen(),
            const UserInformationScreen(),
          ],
        ),
        bottomNavigationBar: DotNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          marginR: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          itemPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          items: [
            DotNavigationBarItem(
              icon: _buildIcon(IconlyBold.home, _selectedIndex == 0),
            ),
            DotNavigationBarItem(
              icon: _buildIcon(Icons.video_collection, _selectedIndex == 1),
            ),
            DotNavigationBarItem(
              icon: Consumer(
                builder: (context, ref, child) {
                  final notif = ref.watch(notificationNotifierProvider);
                  return _buildIcon(
                    IconlyBold.notification,
                    _selectedIndex == 2,
                    badgeCount: notif.unreadCount.value,
                  );
                },
              ),
            ),
            DotNavigationBarItem(
              icon: _buildIcon(IconlyBold.profile, _selectedIndex == 3),
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
      ),
    );
  }
}
