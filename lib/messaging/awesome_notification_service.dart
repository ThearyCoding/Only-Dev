import 'dart:convert';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

class AwesomeNotificationService {
  static late GoRouter _router;

  static void initialize(GoRouter router) {
    _router = router;
    initNotification();
  }

  static Future<void> initNotification() async {
    await AwesomeNotifications().initialize(
    null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
      ],
    );

    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    log("onNotificationCreatedMethod");
  }

  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  static Future<void> onDismissActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload ?? {};
    final courseId = payload['courseId'];
    final categoryId = payload['categoryId'];
    final courseTitle = payload['title'];

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
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, String> payload,
    final String? bigPicture,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: createUniqueId(),
          channelKey: 'basic_channel',
          title: title,
          body: body,
          payload: payload,
          bigPicture: bigPicture),
    );
  }

  static Future<void> handleNotificationTap(String payloadJson) async {
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
  }

  static int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}
