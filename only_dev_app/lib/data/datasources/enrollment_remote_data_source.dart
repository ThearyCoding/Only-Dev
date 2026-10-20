import '../../service/api/api_endpoints.dart';
import '../../service/api/dio_client.dart';
import '../models/models.dart';

abstract class EnrollmentRemoteDataSource {
  Future<List<EnrollmentModel>> getMyEnrollments();
  Future<bool> checkEnrollment(String courseId);
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'});
  Future<void> updateProgress(String courseId, String lessonId, {int? positionSeconds, bool? markCompleted});
}

class EnrollmentRemoteDataSourceImpl implements EnrollmentRemoteDataSource {
  final DioClient _dioClient;

  EnrollmentRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<EnrollmentModel>> getMyEnrollments() async {
    final response = await _dioClient.get(ApiEndpoints.myCourses);
    if (response.data != null && response.data['data'] is List) {
      final list = response.data['data'] as List;
      return list
          .map((item) => EnrollmentModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> checkEnrollment(String courseId) async {
    final response = await _dioClient.get(ApiEndpoints.checkEnrollment(courseId));
    if (response.data != null && response.data['data'] != null) {
      final data = response.data['data'];
      return (data['is_enrolled'] ?? data['isEnrolled'] ?? data['is_registered'] ?? data['isRegistered'] ?? false) as bool;
    }
    return false;
  }

  @override
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'}) async {
    final response = await _dioClient.post(
      ApiEndpoints.enrollments,
      data: {
        'courseId': courseId,
        'enrollmentType': enrollmentType,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      return EnrollmentModel.fromMap(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to enroll in course');
  }

  @override
  Future<void> updateProgress(
    String courseId,
    String lessonId, {
    int? positionSeconds,
    bool? markCompleted,
  }) async {
    await _dioClient.post(
      ApiEndpoints.courseProgress(courseId),
      data: {
        'lessonId': lessonId,
        if (positionSeconds != null) 'positionSeconds': positionSeconds,
        if (markCompleted != null) 'markCompleted': markCompleted,
      },
    );
  }
}

