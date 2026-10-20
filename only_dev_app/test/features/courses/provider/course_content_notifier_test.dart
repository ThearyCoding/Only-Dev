import 'dart:async';
import 'package:better_player/src/configuration/better_player_buffering_configuration.dart';
import 'package:better_player/src/video_player/video_player_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';
import 'package:only_dev_app/features/courses/provider/course_content_notifier.dart';
import 'package:only_dev_app/model/lecture_model.dart';
import 'package:only_dev_app/model/section_model.dart';
import 'package:only_dev_app/service/shared/shared_preferences_service.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  bool get isMock => true;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create({BetterPlayerBufferingConfiguration? bufferingConfiguration}) async => 1;

  @override
  Future<void> setDataSource(int? textureId, DataSource dataSource) async {}

  @override
  Stream<VideoEvent> videoEventsFor(int? textureId) => const Stream.empty();

  @override
  Future<void> setLooping(int? textureId, bool looping) async {}

  @override
  Future<void> play(int? textureId) async {}

  @override
  Future<void> pause(int? textureId) async {}

  @override
  Future<void> setVolume(int? textureId, double volume) async {}

  @override
  Future<void> setSpeed(int? textureId, double speed) async {}

  @override
  Future<void> seekTo(int? textureId, Duration? position) async {}

  @override
  Future<Duration> getPosition(int? textureId) async => Duration.zero;

  @override
  Future<void> dispose(int? textureId) async {}
}

class MockCourseRepository implements CourseRepository {
  CourseModel? courseToReturn;

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  }) async =>
      [];

  @override
  Future<CourseModel> getCourseById(String id) async {
    return courseToReturn ??
        CourseModel(
          id: id,
          title: 'Course Test',
          imageUrl: 'https://example.com/test.jpg',
          categoryId: 'cat-456',
          adminId: 'admin-1',
          sections: [
            Section(
              id: 'sec-1',
              title: 'Section 1',
              learningObjective: 'Learn basics',
              courseId: id,
              lectures: [
                Lecture(
                  id: 'lec-1',
                  title: 'Lesson 1',
                  description: 'Introduction Lesson',
                  videoUrl: '', // Non-streaming
                  sectionId: 'sec-1',
                  thumbnailUrl: '',
                  videoDuration: 120,
                  views: 10,
                ),
                Lecture(
                  id: 'lec-2',
                  title: 'Lesson 2',
                  description: 'Deep Dive Lesson',
                  videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
                  sectionId: 'sec-1',
                  thumbnailUrl: '',
                  videoDuration: 300,
                  views: 50,
                ),
              ],
            ),
          ],
        );
  }
}

class MockEnrollmentRepository implements EnrollmentRepository {
  @override
  Future<bool> checkEnrollment(String courseId) async => true;

  @override
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'}) async =>
      EnrollmentModel(
        id: 'enr-1',
        userId: 'usr-1',
        courseId: courseId,
        status: 'active',
        enrolledAt: DateTime.now().toIso8601String(),
      );

  @override
  Future<List<EnrollmentModel>> getMyEnrollments({int page = 1, int limit = 20, String? status}) async =>
      [];

  @override
  Future<void> updateProgress(
    String courseId,
    String lectureId, {
    int? positionSeconds,
    bool? markCompleted,
  }) async {}
}

class MockQuizRepository implements QuizRepository {
  int totalQuestionsToReturn = 10;

  @override
  Future<int> fetchTotalQuestions(String courseId) async => totalQuestionsToReturn;

  @override
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId) async => [];

  @override
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async => {};

  @override
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data) async => {};
}

class MockSharedPreferencesService extends SharedPreferencesService {
  @override
  Future<Map<String, dynamic>?> getSectionExpanded(String courseId) async => null;

  @override
  Future<Map<String, dynamic>?> getSavedVideoProgress(String videoUrl) async => null;

  @override
  Future<void> saveSectionExpanded(
    String courseId,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
  ) async {}

  @override
  Future<void> saveVideoProgress(
    String videoUrl,
    String sectionId,
    int sectionIndex,
    String lectureId,
    int lectureIndex,
    int position,
    int duration,
    String courseId,
  ) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCourseRepository mockCourseRepo;
  late MockEnrollmentRepository mockEnrollmentRepo;
  late MockQuizRepository mockQuizRepo;
  late MockSharedPreferencesService mockPrefsService;
  late CourseContentNotifier notifier;

  setUpAll(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  setUp(() {
    mockCourseRepo = MockCourseRepository();
    mockEnrollmentRepo = MockEnrollmentRepository();
    mockQuizRepo = MockQuizRepository();
    mockPrefsService = MockSharedPreferencesService();

    notifier = CourseContentNotifier(
      courseRepository: mockCourseRepo,
      enrollmentRepository: mockEnrollmentRepo,
      quizRepository: mockQuizRepo,
      sharedPreferencesService: mockPrefsService,
      courseId: 'course-123',
      categoryId: 'cat-456',
    );
  });

  tearDown(() {
    notifier.dispose();
  });

  group('CourseContentNotifier & State Tests', () {
    test('Initial state should be loading with default properties', () {
      expect(notifier.state.isLoading, isTrue);
      expect(notifier.state.sections, isEmpty);
      expect(notifier.state.currentLecture, isNull);
      expect(notifier.state.isPanelOpen, isFalse);
      expect(notifier.state.activeTabIndex, 0);
    });

    test('initialize populates sections and selects first playable lecture', () async {
      await notifier.initialize();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.sections.length, 1);
      // Lesson 1 had empty videoUrl, so Lesson 2 should be selected
      expect(notifier.state.selectedLectureId, 'lec-2');
      expect(notifier.state.currentLecture?.title, 'Lesson 2');
    });

    test('setActiveTab updates activeTabIndex and fetches total questions when tab is 1', () async {
      expect(notifier.state.totalQuestions, 0);

      notifier.setActiveTab(1);

      expect(notifier.state.activeTabIndex, 1);
      // Wait for fetchTotalQuestions async completion
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.totalQuestions, 10);
    });

    test('setPanelOpen toggles isPanelOpen state flag', () {
      expect(notifier.state.isPanelOpen, isFalse);

      notifier.setPanelOpen(true);
      expect(notifier.state.isPanelOpen, isTrue);

      notifier.setPanelOpen(false);
      expect(notifier.state.isPanelOpen, isFalse);
    });

    test('CourseContentParams equality and hashCode work correctly', () {
      const param1 = CourseContentParams(courseId: 'c1', categoryId: 'cat1');
      const param2 = CourseContentParams(courseId: 'c1', categoryId: 'cat1');
      const param3 = CourseContentParams(courseId: 'c2', categoryId: 'cat1');

      expect(param1, equals(param2));
      expect(param1.hashCode, equals(param2.hashCode));
      expect(param1 == param3, isFalse);
    });
  });
}
