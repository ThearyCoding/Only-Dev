import 'dart:developer';
import 'package:only_dev_app/service/firebase/firebase_api_lecture.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/registration_model.dart';
import 'package:only_dev_app/service/firebase/firebase_api_registration.dart';
import 'package:only_dev_app/service/firebase/firebase_api_user.dart';
import 'package:uuid/uuid.dart';
import 'package:only_dev_app/messaging/local_notification_service.dart';
import 'package:only_dev_app/model/notification_model.dart';
import 'package:only_dev_app/service/firebase/firebase_api_notifications.dart';

class RegistrationProvider extends ChangeNotifier {
  final FirebaseApiRegistration _courseRegistrationService =
      locator<FirebaseApiRegistration>();
  final UserService userService = locator<UserService>();
  final FirebaseApiLecture _apiLecture = locator<FirebaseApiLecture>();
  List<RegistrationModel> registeredCourses = [];
  final FirebaseApiNotifications _apiNotifications =
      locator<FirebaseApiNotifications>();
  Map<String, int> totalLecturesMap = {};
  Map<String, int> watchedLecturesMap = {};
  final User? user = locator<FirebaseAuth>().currentUser;
  bool hasShownDialog = false;
  bool isLoading = true;
  bool isCancelled = false;

  RegistrationProvider() {
    init();
  }

  Future<void> init() async {
    await fetchAllRegistrations(user!.uid);
  }

  Future<void> fetchAllRegistrations(String userId) async {
    try {
      final registrations =
          await _courseRegistrationService.getUserRegisteredCourses(userId);
      registeredCourses = registrations;

      // Concurrently fetch total lectures and watched lectures
      await Future.wait([
        _fetchTotalLecturesForCourses(),
        _fetchWatchedLecturesForCourses(),
      ]);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Failed to fetch registrations: $e');
      notifyListeners();
    }
  }

  Future<void> registerUser(
      String userId, String courseId, String categoryId, String title) async {
    if (isCancelled) {
      log('Registration cancelled.');
      return;
    }
    String registerId = const Uuid().v1();
    String notificationId = const Uuid().v1();
    await _courseRegistrationService.checkAndRegisterUser(
      userId: userId,
      courseId: courseId,
      categoryId: categoryId,
      id: registerId,
    );
    await _sendPushNotification(
      userId,
      title,
      "You have successfully registered for the course.",
      courseId,
      categoryId,
    );
    NotificationModel notification = NotificationModel(
      registerId: registerId,
      title: 'Registration Successful',
      message: 'You have successfully registered for the course: $title.',
      timestamp: DateTime.now(),
      courseId: courseId,
      id: notificationId,
      isRead: false,
      type: 'course',
      categoryId: categoryId,
    );

    await _apiNotifications.saveNotification(notification, userId);
    await fetchAllRegistrations(userId);
    hasShownDialog = false;
    notifyListeners();
  }

  Future<void> _sendPushNotification(String userId, String title, String body,
      String courseId, String categoryId) async {
    try {
      // final response = await http.post(
      //   Uri.parse('$baseUrl/api/notifications/send-notification'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json; charset=UTF-8',
      //   },
      //   body: jsonEncode(<String, String>{
      //     'uid': userId,
      //     'title': title,
      //     'body': body,
      //     'courseId': courseId,
      //     'categoryId': categoryId,
      //   }),
      // );

      // if (response.statusCode == 200) {
      //   log('Notification sent successfully');
      // } else {
      //   log('Failed to send notification');
      //   log('Response body: ${response.body}');
      // }

      final payload = {
        'uid': userId,
        'title': title,
        'body': body,
        'courseId': courseId,
        'categoryId': categoryId,
      };

      await LocalNotificationService.showNotification(
          title: title, body: body, payload: payload);
    } catch (e) {
      log('Failed to send notification: $e');
    }
  }

  bool isUserRegisteredForCourse(String courseId) {
    return registeredCourses.any((course) => course.courseId == courseId);
  }

  Future<void> _fetchTotalLecturesForCourses() async {
    Map<String, int> totalLectures = {};
    List<Future<void>> fetchTasks = [];
    for (var course in registeredCourses) {
      fetchTasks.add(
        _apiLecture
            .getTotalLectures(course.categoryId, course.courseId)
            .then((lectures) {
          totalLectures[course.courseId] = lectures;
        }),
      );
    }
    await Future.wait(fetchTasks);
    totalLecturesMap = totalLectures;
    notifyListeners();
  }

  Future<void> _fetchWatchedLecturesForCourses() async {
    Map<String, int> watchedLectures = {};
    List<Future<void>> fetchTasks = [];
    for (var course in registeredCourses) {
      fetchTasks.add(
        userService
            .getWatchedLecturesForCourse(course.courseId)
            .then((watchedData) {
          int watchedLessons = watchedData.values
              .map((sections) =>
                  (sections as Map<String, dynamic>).values.length)
              .fold(0, (prev, curr) => prev + curr);
          watchedLectures[course.courseId] = watchedLessons;
        }),
      );
    }
    await Future.wait(fetchTasks);
    watchedLecturesMap = watchedLectures;
    notifyListeners();
  }
}
