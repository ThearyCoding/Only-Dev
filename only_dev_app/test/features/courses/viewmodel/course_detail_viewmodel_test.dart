import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';
import 'package:only_dev_app/features/courses/viewmodel/course_detail_viewmodel.dart';

class FakeCourseRepository implements CourseRepository {
  bool shouldThrow = false;
  CourseModel? courseToReturn;

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  }) async {
    return [];
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    if (shouldThrow) {
      throw Exception('Failed to load course details');
    }
    return courseToReturn ??
        CourseModel(
          id: id,
          title: 'Flutter Masterclass',
          imageUrl: 'https://example.com/thumbnail.png',
          categoryId: 'cat-1',
          adminId: 'admin-1',
          isEnrolled: false,
        );
  }
}

class FakeEnrollmentRepository implements EnrollmentRepository {
  bool isEnrolled = false;
  bool shouldThrow = false;
  bool enrollCalled = false;

  @override
  Future<bool> checkEnrollment(String courseId) async {
    if (shouldThrow) throw Exception('Check enrollment failed');
    return isEnrolled;
  }

  @override
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'}) async {
    enrollCalled = true;
    isEnrolled = true;
    return EnrollmentModel(
      id: 'enr-123',
      userId: 'usr-123',
      courseId: courseId,
      status: 'active',
      enrolledAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<EnrollmentModel>> getMyEnrollments() async => [];

  @override
  Future<void> updateProgress(
    String courseId,
    String lessonId, {
    int? positionSeconds,
    bool? markCompleted,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseDetailViewModel Enrollment Verification Tests', () {
    late FakeCourseRepository fakeCourseRepo;
    late FakeEnrollmentRepository fakeEnrollmentRepo;
    late CourseDetailViewModel viewModel;

    setUp(() {
      fakeCourseRepo = FakeCourseRepository();
      fakeEnrollmentRepo = FakeEnrollmentRepository();
      viewModel = CourseDetailViewModel(fakeCourseRepo, fakeEnrollmentRepo);
    });

    test('Initial state should be idle with isEnrolled false', () {
      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isEnrolled, isFalse);
      expect(viewModel.course, isNull);
    });

    test('init populates isEnrolled=true when course model returns isEnrolled=true', () async {
      fakeCourseRepo.courseToReturn = CourseModel(
        id: 'course-123',
        title: 'AI Agents with Python',
        imageUrl: '',
        categoryId: 'cat-ai',
        adminId: 'admin-1',
        isEnrolled: true,
      );
      fakeEnrollmentRepo.isEnrolled = false;

      await viewModel.init('course-123');

      expect(viewModel.state, equals(ViewState.success));
      expect(viewModel.course, isNotNull);
      expect(viewModel.isEnrolled, isTrue);
    });

    test('init populates isEnrolled=true when checkEnrollment returns true', () async {
      fakeCourseRepo.courseToReturn = CourseModel(
        id: 'course-456',
        title: 'NestJS Clean Architecture',
        imageUrl: '',
        categoryId: 'cat-backend',
        adminId: 'admin-1',
        isEnrolled: false,
      );
      fakeEnrollmentRepo.isEnrolled = true;

      await viewModel.init('course-456');

      expect(viewModel.state, equals(ViewState.success));
      expect(viewModel.isEnrolled, isTrue);
    });

    test('enrollInCourse updates isEnrolled flag on successful enrollment', () async {
      fakeCourseRepo.courseToReturn = CourseModel(
        id: 'course-789',
        title: 'Flutter UI Design',
        imageUrl: '',
        categoryId: 'cat-flutter',
        adminId: 'admin-1',
        isEnrolled: false,
      );

      await viewModel.init('course-789');
      expect(viewModel.isEnrolled, isFalse);

      final success = await viewModel.enrollInCourse();
      expect(success, isTrue);
      expect(viewModel.isEnrolled, isTrue);
      expect(fakeEnrollmentRepo.enrollCalled, isTrue);
    });
  });
}
