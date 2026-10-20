import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/courses/view/course_detail_view.dart';
import 'package:only_dev_app/features/courses/viewmodel/course_detail_viewmodel.dart';
import 'package:only_dev_app/generated/l10n.dart';

class MockCourseRepo implements CourseRepository {
  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  }) async => [];

  @override
  Future<CourseModel> getCourseById(String id) async {
    return CourseModel(
      id: id,
      title: 'Applied AI & LLMs with Python',
      description: 'Learn how to build AI agents.',
      imageUrl: 'https://example.com/cover.png',
      categoryId: 'artificial-intelligence',
      adminId: 'admin-1',
      price: 79.99,
      ratingAvg: 4.8,
      ratingCount: 120,
      registerCounts: 450,
      isEnrolled: false,
    );
  }
}

class MockEnrollmentRepo implements EnrollmentRepository {
  @override
  Future<bool> checkEnrollment(String courseId) async => false;

  @override
  Future<EnrollmentModel> enroll(String courseId, {String enrollmentType = 'free'}) async {
    return EnrollmentModel(
      id: 'enr-1',
      userId: 'usr-1',
      courseId: courseId,
      status: 'active',
      enrolledAt: '2026-10-20',
    );
  }

  @override
  Future<List<EnrollmentModel>> getMyEnrollments() async => [];

  @override
  Future<void> updateProgress(String courseId, String lessonId, {int? positionSeconds, bool? markCompleted}) async {}
}

void main() {
  setUp(() {
    if (locator.isRegistered<CourseDetailViewModel>()) {
      locator.unregister<CourseDetailViewModel>();
    }
    locator.registerFactory<CourseDetailViewModel>(
      () => CourseDetailViewModel(MockCourseRepo(), MockEnrollmentRepo()),
    );
  });

  tearDown(() {
    if (locator.isRegistered<CourseDetailViewModel>()) {
      locator.unregister<CourseDetailViewModel>();
    }
  });

  testWidgets('CourseDetailView renders hero, content, and sticky bottom bar correctly', (tester) async {
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: CourseDetailView(
            courseId: 'course-123',
            categoryId: 'cat-1',
          ),
        ),
      ),
    );

    // Initial pump for model.init()
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify course details are rendered
    expect(find.text('Applied AI & LLMs with Python'), findsWidgets);
    expect(find.text('\$79.99'), findsOneWidget);
    expect(find.text('Enroll Now'), findsOneWidget);
    expect(find.text('About Course'), findsOneWidget);

    // Verify CustomScrollView has non-zero height (not crushed to 0)
    final customScrollViewFinder = find.byType(CustomScrollView);
    expect(customScrollViewFinder, findsOneWidget);
    final size = tester.getSize(customScrollViewFinder);
    expect(size.height, greaterThan(500.0));

    // Drain PaletteGenerator 15s timeout timer
    await tester.pump(const Duration(seconds: 16));
  });
}
