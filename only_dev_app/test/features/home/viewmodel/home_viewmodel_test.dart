import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/features/home/model/home_screen_data.dart';
import 'package:only_dev_app/features/home/repository/home_repository.dart';
import 'package:only_dev_app/features/home/viewmodel/home_viewmodel.dart';
import 'package:only_dev_app/model/banner_model.dart';
import 'package:only_dev_app/model/category_model.dart';
import 'package:only_dev_app/model/courses_model.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldThrow = false;
  HomeScreenData? dataToReturn;

  @override
  Future<HomeScreenData> getHomeScreenData() async {
    if (shouldThrow) {
      throw Exception('Server error: 500');
    }
    return dataToReturn ??
        HomeScreenData(
          banners: [
            BannerModel(id: 'b1', imageUrl: 'https://example.com/banner1.jpg'),
          ],
          categories: [
            CategoryModel(id: 'c1', title: 'Flutter', imageUrl: 'https://example.com/cat1.jpg'),
          ],
          courses: [
            CourseModel(id: 'course1', title: 'Flutter Core', imageUrl: 'thumb.jpg', categoryId: 'c1', adminId: 'u1'),
          ],
          recentCourses: [
            CourseModel(id: 'course2', title: 'Recent Course', imageUrl: 'thumb2.jpg', categoryId: 'c1', adminId: 'u1'),
          ],
          popularCourses: [
            CourseModel(id: 'course3', title: 'Popular Course', imageUrl: 'thumb3.jpg', categoryId: 'c1', adminId: 'u1'),
          ],
        );
  }
}

void main() {
  group('HomeViewModel Tests', () {
    late FakeHomeRepository fakeRepository;
    late HomeViewModel viewModel;

    setUp(() {
      fakeRepository = FakeHomeRepository();
      viewModel = HomeViewModel(fakeRepository);
    });

    test('Initial state should be idle with empty lists', () {
      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isBusy, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.homeData, isNull);
      expect(viewModel.banners, isEmpty);
      expect(viewModel.categories, isEmpty);
      expect(viewModel.courses, isEmpty);
      expect(viewModel.recentCourses, isEmpty);
      expect(viewModel.popularCourses, isEmpty);
    });

    test('fetchHomeData sets success state and populates all screen resources in a single call', () async {
      await viewModel.fetchHomeData();

      expect(viewModel.state, equals(ViewState.success));
      expect(viewModel.isBusy, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.homeData, isNotNull);
      expect(viewModel.banners.length, equals(1));
      expect(viewModel.banners.first.id, equals('b1'));
      expect(viewModel.categories.length, equals(1));
      expect(viewModel.categories.first.title, equals('Flutter'));
      expect(viewModel.courses.length, equals(1));
      expect(viewModel.recentCourses.length, equals(1));
      expect(viewModel.popularCourses.length, equals(1));
    });

    test('fetchHomeData handles error gracefully when repository fails', () async {
      fakeRepository.shouldThrow = true;

      await viewModel.fetchHomeData();

      expect(viewModel.state, equals(ViewState.error));
      expect(viewModel.isBusy, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Server error: 500'));
      expect(viewModel.homeData, isNull);
    });

    test('fetchHomeData skips duplicate call if data already fetched unless refresh is true', () async {
      await viewModel.fetchHomeData();
      expect(viewModel.banners.length, equals(1));

      // Change repo return
      fakeRepository.dataToReturn = HomeScreenData(
        banners: [
          BannerModel(id: 'b1', imageUrl: 'https://example.com/banner1.jpg'),
          BannerModel(id: 'b2', imageUrl: 'https://example.com/banner2.jpg'),
        ],
        categories: [],
        courses: [],
        recentCourses: [],
        popularCourses: [],
      );

      // Calling without refresh should return cached in-memory data
      await viewModel.fetchHomeData();
      expect(viewModel.banners.length, equals(1));

      // Calling with refresh = true should reload
      await viewModel.fetchHomeData(refresh: true);
      expect(viewModel.banners.length, equals(2));
    });
  });
}

