import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:e_leaningapp/providers/notification_provider.dart';
import 'package:e_leaningapp/screens/user-screens/user_information_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../export/export.dart';
import '../../utils/show_error_utils.dart';
import '../home-screen/home_screen.dart';
import '../notification-screen/notification_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool isConnectedToInternet = true;
  bool wasConnectedToInternet = true;
  int _selectedIndex = 0;
  late NotificationProvider notificationProvider;
  @override
  void initState() {
    super.initState();

    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    //   isConnected();
    
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        notificationProvider.markAllAsRead();
      }
    });
  }

  Widget _buildIcon(IconData icon, bool isSelected, {int? badgeCount}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
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
              isLabelVisible: badgeCount == 0 ? false : true,
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
        body: Stack(
          children: [
            Offstage(
                offstage: _selectedIndex != 0,
                child: MyHomePage(
                  onSeeAllCoursesTapped: _onSeeAllCourses,
                  onProfileImageTapped: _onProfileImageTapped,
                  onNotificationsTapped: _onNotificationTapped,
                )),
            Offstage(
                offstage: _selectedIndex != 1, child: const AllCoursesScreen()),
            Offstage(
                offstage: _selectedIndex != 2,
                child: const NotificationsScreen()),
            Offstage(
                offstage: _selectedIndex != 3,
                child: const UserInformationScreen()),
          ],
        ),
        //  extendBody: true,
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
            DotNavigationBarItem(icon: Consumer<NotificationProvider>(
              builder: (context, value, child) {
                return _buildIcon(
                  IconlyBold.notification,
                  _selectedIndex == 2,
                  badgeCount: notificationProvider.unreadCount.value,
                );
              },
            )),
            DotNavigationBarItem(
              icon: _buildIcon(IconlyBold.profile, _selectedIndex == 3),
            ),
          ],
          dotIndicatorColor: Colors.blue,
          backgroundColor:
              isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          enablePaddingAnimation: false,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          paddingR: const EdgeInsets.all(8),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  Timer?
      connectionLostTimer; // Timer to repeatedly show snackbar when connection is lost

  void isConnected() {
    InternetConnectionUtils.listenToInternetConnectionStatus(
      (bool isConnected) {
        if (isConnected != wasConnectedToInternet) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                isConnectedToInternet = isConnected;

                if (!isConnected) {
                  // Start or restart the timer to show snackbar every 30 seconds
                  connectionLostTimer?.cancel(); // Cancel any existing timer
                  showSnackbar(
                    'Please check your internet connection!',
                  );
                  connectionLostTimer =
                      Timer.periodic(const Duration(seconds: 10), (_) {
                    showSnackbar(
                      'Please check your internet connection!',
                    );
                  });
                } else {
                  connectionLostTimer?.cancel(); // Cancel the timer
                  showSnackbar(
                    'Internet connection is back!',
                  );
                }

                // Update the wasConnectedToInternet variable
                wasConnectedToInternet = isConnected;
              });
            }
          });
        }
      },
    );
  }
}