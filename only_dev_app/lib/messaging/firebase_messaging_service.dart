import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../routes/app_routes.dart';
import 'local_notification_service.dart';

class FirebaseMessagingService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await SharedPreferences.getInstance();
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      LocalNotificationService.initialize(AppRoutes.router);
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null && message.data.isNotEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          LocalNotificationService.handleNotificationTap(
              jsonEncode(message.data));
        });
      }
    } catch (e) {
      debugPrint('FirebaseMessagingService initialization error: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    LocalNotificationService.showNotification(
      title: message.data['title'] ?? '',
      body: message.data['body'] ?? '',
      payload:
          message.data.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static void configureMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        LocalNotificationService.showNotification(
          title: message.data['title'] ?? '',
          body: message.data['body'] ?? '',
          payload:
              message.data.map((key, value) => MapEntry(key, value.toString())),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LocalNotificationService.handleNotificationTap(
          jsonEncode(message.data));
    });
  }
}
