import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';

class EnrollmentsViewModel extends BaseViewModel {
  final EnrollmentRepository _enrollmentRepository;

  List<EnrollmentModel> _enrollments = [];
  List<EnrollmentModel> get enrollments => _enrollments;

  List<EnrollmentModel> get ongoingEnrollments =>
      _enrollments.where((e) => !e.isCompleted && e.percentComplete < 100).toList();

  List<EnrollmentModel> get completedEnrollments =>
      _enrollments.where((e) => e.isCompleted || e.percentComplete >= 100).toList();

  EnrollmentsViewModel(this._enrollmentRepository);

  Future<void> fetchMyEnrollments() async {
    setBusy(true);
    try {
      final results = await _enrollmentRepository.getMyEnrollments();
      _enrollments = results;
      setViewState(ViewState.success);
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> updatePlaybackProgress({
    required String courseId,
    required String lessonId,
    int? positionSeconds,
    bool? markCompleted,
  }) async {
    try {
      await _enrollmentRepository.updateProgress(
        courseId,
        lessonId,
        positionSeconds: positionSeconds,
        markCompleted: markCompleted,
      );

      // Locally refresh enrollment progress state
      fetchMyEnrollments();
    } catch (e) {
      // Background progress sync failure handled gracefully
    }
  }
}
