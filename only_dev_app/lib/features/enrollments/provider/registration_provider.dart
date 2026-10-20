import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/registration_model.dart';
import 'package:only_dev_app/messaging/local_notification_service.dart';

class RegistrationProvider extends ChangeNotifier {
  final EnrollmentRepository _enrollmentRepository =
      locator<EnrollmentRepository>();
  List<RegistrationModel> registeredCourses = [];
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
    final uid = user?.uid;
    if (uid != null) {
      await fetchAllRegistrations(uid);
    } else {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllRegistrations(String userId) async {
    try {
      final enrollments = await _enrollmentRepository.getMyEnrollments();
      registeredCourses =
          enrollments.map((e) => RegistrationModel.fromEnrollment(e)).toList();

      for (var e in enrollments) {
        if (e.course != null) {
          totalLecturesMap[e.courseId] = e.course!.totalLessons ?? 0;
          final totalLessons = e.course!.totalLessons ?? 0;
          watchedLecturesMap[e.courseId] =
              ((e.percentComplete / 100) * totalLessons).round();
        }
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Failed to fetch registrations: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerUser(
      String userId, String courseId, String categoryId, String title) async {
    if (isCancelled) {
      log('Registration cancelled.');
      return;
    }
    try {
      await _enrollmentRepository.enroll(courseId);
      await _sendPushNotification(
        userId,
        title,
        "You have successfully registered for the course.",
        courseId,
        categoryId,
      );
      await fetchAllRegistrations(userId);
      hasShownDialog = false;
      notifyListeners();
    } catch (e) {
      log('Error registering for course: $e');
    }
  }

  Future<void> _sendPushNotification(String userId, String title, String body,
      String courseId, String categoryId) async {
    try {
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
}
