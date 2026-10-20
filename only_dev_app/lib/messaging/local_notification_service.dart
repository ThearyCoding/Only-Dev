import 'dart:convert';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static late GoRouter _router;

  static void initialize(GoRouter router) {
    _router = router;
    initNotification();
  }

  static Future<void> initNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null && response.payload!.isNotEmpty) {
          handleNotificationTap(response.payload!);
        }
      },
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, String> payload,
    final String? bigPicture,
  }) async {
    try {
      final id = createUniqueId();
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'pushnotificationapp',
        'pushnotificationchannel',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(payload),
      );
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  static Future<void> handleNotificationTap(String payloadJson) async {
    try {
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      final courseId = payload['courseId'];
      final categoryId = payload['categoryId'];
      final courseTitle = payload['title'];

      log('Handling notification tap with courseId: $courseId');
      if (courseId != null && categoryId != null) {
        if (courseTitle != null) {
          _router.push(
            RoutesPath.detailCourseScreen,
            extra: {
              'categoryId': categoryId,
              'courseId': courseId,
            },
          );
        } else {
          _router.push(
            RoutesPath.topicScreen,
            extra: {
              'courseId': courseId,
              'categoryId': categoryId,
              'title': courseTitle,
            },
          );
        }
      } else {
        log('Missing courseId, categoryId, or courseTitle.');
      }
    } catch (e) {
      log('Error handling notification tap: $e');
    }
  }

  static int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}

