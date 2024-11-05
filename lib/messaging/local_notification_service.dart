// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import '../export/export.dart';

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static void init() {
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     );

//     _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         if (response.payload != null && response.payload!.isNotEmpty) {
//           handleNotificationTap(response.payload!);
//           debugPrint('Notification payload: ${response.payload}');
//         }
//       },
//       onDidReceiveBackgroundNotificationResponse: (response) {
//         if (response.payload != null && response.payload!.isNotEmpty) {
//           handleNotificationTap(response.payload!);
//           debugPrint('Notification payload: ${response.payload}');
//         }
//       },
//     );
//   }

//   static void handleNotificationTap(String payload) {
//     try {
//       final data = jsonDecode(payload);
//       final courseId = data['courseId'];
//       final categoryId = data['categoryId'];
//       final courseTitle = data['title'];

//       debugPrint('Handling notification tap with courseId: $courseId');

//       if (courseId != null && categoryId != null && courseTitle != null) {
//         Get.toNamed(
//           RoutesPath.topicScreen,
//           arguments: {
//             'courseId': courseId,
//             'categoryId': categoryId,
//             'title': courseTitle,
//           },
//         );
//       } else {
//         debugPrint('Missing courseId or categoryId in notification payload');
//       }
//     } catch (e) {
//       debugPrint('Error handling notification tap: $e');
//     }
//   }

//   static Future<void> createNotification(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       final payload = jsonEncode(message.data);
//       debugPrint('Creating notification with payload: $payload');
//       const NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//           'pushnotificationapp',
//           'pushnotificationchannel',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       );
//       await _notificationsPlugin.show(
//         id,
//         message.notification?.title,
//         message.notification?.body,
//         notificationDetails,
//         payload: payload,
//       );
//     } catch (e) {
//       debugPrint('Error showing notification: $e');
//     }
//   }
// }
