import 'package:e_leaningapp/messaging/awesome_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../export/export.dart';

class FirebaseMessagingService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await SharedPreferences.getInstance();
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
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
    final router = AppRoutes.getRouter();
    AwesomeNotificationService.initNotification();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    AwesomeNotificationService.initialize(router);
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      Future.delayed(const Duration(seconds: 1), () {
        AwesomeNotificationService.handleNotificationTap(
            jsonEncode(message.data));
      });
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    AwesomeNotificationService.showNotification(
      title: message.data['title'] ?? '',
      body: message.data['body'] ?? '',
      payload:
          message.data.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static void configureMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        AwesomeNotificationService.showNotification(
          title: message.data['title'] ?? '',
          body: message.data['body'] ?? '',
          payload:
              message.data.map((key, value) => MapEntry(key, value.toString())),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AwesomeNotificationService.handleNotificationTap(
          jsonEncode(message.data));
    });
  }
}
