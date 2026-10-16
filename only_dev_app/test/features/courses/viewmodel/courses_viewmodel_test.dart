import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/features/courses/viewmodel/courses_viewmodel.dart';

class FakeCourseRepository implements CourseRepository {
  bool shouldThrow = false;
  List<CourseModel> coursesToReturn = [];

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  }) async {
    if (shouldThrow) {
      throw Exception('Network connection failure');
    }
    return coursesToReturn;
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    if (shouldThrow) {
      throw Exception('Course not found');
    }
    return CourseModel(
      id: id,
      title: 'Sample Course',
      imageUrl: 'https://example.com/sample.png',
      categoryId: 'cat_sample',
      adminId: 'admin_sample',
    );
  }
}

void main() {
  group('CoursesViewModel Tests', () {
    late FakeCourseRepository fakeRepository;
    late CoursesViewModel viewModel;

    setUp(() {
      fakeRepository = FakeCourseRepository();
      viewModel = CoursesViewModel(fakeRepository);
    });

    test('Initial state should be idle with empty courses list', () {
      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isBusy, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.courses, isEmpty);
      expect(viewModel.selectedCategory, isNull);
    });

    test('fetchCourses sets success state and populates courses on success', () async {
      fakeRepository.coursesToReturn = [
        CourseModel(
          id: 'c1',
          title: 'Flutter MVVM Masterclass',
          imageUrl: 'https://example.com/c1.png',
          categoryId: 'mobile',
          adminId: 'instructor1',
        ),
        CourseModel(
          id: 'c2',
          title: 'NestJS Backend Architecture',
          imageUrl: 'https://example.com/c2.png',
          categoryId: 'backend',
          adminId: 'instructor2',
        ),
      ];

      await viewModel.fetchCourses(category: 'Mobile');

      expect(viewModel.state, equals(ViewState.success));
      expect(viewModel.isBusy, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.courses.length, equals(2));
      expect(viewModel.courses[0].title, equals('Flutter MVVM Masterclass'));
      expect(viewModel.selectedCategory, equals('Mobile'));
    });

    test('fetchCourses sets error state and records errorMessage on failure', () async {
      fakeRepository.shouldThrow = true;

      await viewModel.fetchCourses();

      expect(viewModel.state, equals(ViewState.error));
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Network connection failure'));
      expect(viewModel.courses, isEmpty);
    });

    test('loadMoreCourses appends additional courses and increments page', () async {
      // First page with 20 items to allow hasMoreCourses
      fakeRepository.coursesToReturn = List.generate(
        20,
        (i) => CourseModel(
          id: 'c_$i',
          title: 'Course $i',
          imageUrl: 'https://example.com/$i.png',
          categoryId: 'cat',
          adminId: 'adm',
        ),
      );
      await viewModel.fetchCourses();
      expect(viewModel.courses.length, equals(20));
      expect(viewModel.hasMoreCourses, isTrue);

      // Load second page
      fakeRepository.coursesToReturn = [
        CourseModel(
          id: 'c_21',
          title: 'Course 21',
          imageUrl: 'https://example.com/21.png',
          categoryId: 'cat',
          adminId: 'adm',
        ),
      ];
      final loaded = await viewModel.loadMoreCourses();

      expect(loaded, isTrue);
      expect(viewModel.courses.length, equals(21));
    });
  });
}
