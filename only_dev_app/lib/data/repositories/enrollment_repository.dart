import '../datasources/enrollment_remote_data_source.dart';
import '../models/models.dart';

abstract class EnrollmentRepository {
  Future<List<EnrollmentModel>> getMyEnrollments();
  Future<bool> checkEnrollment(String courseId);
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'});
  Future<void> updateProgress(String courseId, String lessonId, {int? positionSeconds, bool? markCompleted});
}

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource _remoteDataSource;

  EnrollmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<EnrollmentModel>> getMyEnrollments() {
    return _remoteDataSource.getMyEnrollments();
  }

  @override
  Future<bool> checkEnrollment(String courseId) {
    return _remoteDataSource.checkEnrollment(courseId);
  }

  @override
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'}) {
    return _remoteDataSource.enroll(courseId, enrollmentType: enrollmentType);
  }

  @override
  Future<void> updateProgress(
    String courseId,
    String lessonId, {
    int? positionSeconds,
    bool? markCompleted,
  }) {
    return _remoteDataSource.updateProgress(
      courseId,
      lessonId,
      positionSeconds: positionSeconds,
      markCompleted: markCompleted,
    );
  }
}

