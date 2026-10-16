import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/enrollment_model.dart';
import 'package:only_dev_app/model/registration_model.dart';
import 'package:only_dev_app/service/api/api_endpoints.dart';
import 'package:only_dev_app/service/api/dio_client.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';

class EnrollmentProvider extends ChangeNotifier {
  final DioClient _dioClient = locator<DioClient>();

  List<EnrollmentModel> enrolledCourses = [];
  bool isLoading = false;
  String? errorMessage;

  EnrollmentProvider() {
    fetchMyEnrollments();
  }

  // Backward compatibility getter for existing UI widgets
  List<RegistrationModel> get registeredCourses =>
      enrolledCourses.map((e) => RegistrationModel.fromEnrollment(e)).toList();

  bool isUserRegisteredForCourse(String courseId) {
    return enrolledCourses.any((e) => e.courseId == courseId && e.isRegistered);
  }

  /// Fetch all active course enrollments with progress from NestJS backend
  Future<void> fetchMyEnrollments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dioClient.get(
        ApiEndpoints.myCourses,
        options: null, // Let error interceptor handle errors
      );

      if (response.data != null && response.data['data'] is List) {
        final list = response.data['data'] as List;
        enrolledCourses = list
            .map((item) => EnrollmentModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        enrolledCourses = [];
      }
    } catch (e) {
      log('Error fetching enrolled courses: $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Check whether the current user is enrolled in a specific course
  Future<bool> checkEnrollment(String courseId) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.checkEnrollment(courseId));
      if (response.data != null && response.data['data'] != null) {
        return (response.data['data']['isEnrolled'] ?? false) as bool;
      }
    } catch (e) {
      log('Error checking enrollment for $courseId: $e');
    }
    return false;
  }

  /// Enroll in a course (free, promo, or paid)
  Future<bool> enrollCourse({
    required String courseId,
    String enrollmentType = 'free',
    Map<String, dynamic>? pricePaid,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dioClient.post(
        ApiEndpoints.enrollments,
        data: {
          'courseId': courseId,
          'enrollmentType': enrollmentType,
          if (pricePaid != null) 'pricePaid': pricePaid,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastUtils.success('Enrolled in course successfully!');
        await fetchMyEnrollments();
        return true;
      }
    } catch (e) {
      log('Enrollment failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Update video playback resume position and completed lesson status
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    int? positionSeconds,
    bool? markCompleted,
  }) async {
    try {
      await _dioClient.post(
        ApiEndpoints.courseProgress(courseId),
        data: {
          'lessonId': lessonId,
          if (positionSeconds != null) 'positionSeconds': positionSeconds,
          if (markCompleted != null) 'markCompleted': markCompleted,
        },
      );
    } catch (e) {
      log('Error updating lesson progress: $e');
    }
  }

  // Backward compatibility alias for existing screens
  Future<void> registerUser(
    String userId,
    String courseId,
    String categoryId,
    String title,
  ) async {
    await enrollCourse(courseId: courseId);
  }
}

