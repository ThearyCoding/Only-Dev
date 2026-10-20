import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/home/repository/home_repository.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/model/category_model.dart';
import 'package:only_dev_app/model/courses_model.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';

class CourseListProvider with ChangeNotifier {
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final HomeRepository _homeRepository = locator<HomeRepository>();

  List<CourseModel> courses = [];
  int _page = 1;
  TabController? tabController;
  String activeFetchId = '';
  bool isLoadingCategories = false;
  bool isPaginating = false;
  bool hasMoreData = true;
  Map<String, UserModel> adminMap = {};
  Map<String, int> quizCounts = {};
  Map<String, bool> categoryLoadingMap = {};
  List<CourseModel> courseByCategoryId = [];
  User? user = locator<FirebaseAuth>().currentUser;
  List<CategoryModel> categories = [];
  String selectedCategory = 'all';
  final int limit = 5;
  final Set<String> courseIds = <String>{};
  final Map<String, List<CourseModel>> categoryCourseCache = {};

  CourseListProvider({required TickerProvider tickerProvider}) {
    fetchCategories(tickerProvider);
  }

  void disposeControllers() {
    tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchCategories(TickerProvider tickerProvider) async {
    try {
      isLoadingCategories = true;
      notifyListeners();
      final homeData = await _homeRepository.getHomeScreenData();
      List<CategoryModel> tempCategories = List.from(homeData.categories);
      tempCategories.insert(
          0, CategoryModel(id: 'all', title: 'All', imageUrl: ''));
      categories = tempCategories;

      tabController =
          TabController(length: categories.length, vsync: tickerProvider);
      for (var category in categories) {
        categoryLoadingMap[category.id] = false;
      }

      notifyListeners();
      fetchCourses();
    } catch (error) {
      AppToastUtils.handleError(error, 'Error fetching categories');
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourses({
    bool isRefresh = false,
    bool isPagination = false,
  }) async {
    if (isPaginating || (categoryLoadingMap[selectedCategory] ?? false)) return;

    if (isPagination) {
      isPaginating = true;
    } else {
      categoryLoadingMap[selectedCategory] = true;
    }
    notifyListeners();

    final currentFetchId = DateTime.now().millisecondsSinceEpoch.toString();
    activeFetchId = currentFetchId;
    final currentCategory = selectedCategory;

    try {
      if (isRefresh) {
        _page = 1;
      } else if (isPagination) {
        _page++;
      }

      final fetchedCourses = await _courseRepository.getCourses(
        page: _page,
        limit: limit,
        category: selectedCategory == 'all' ? null : selectedCategory,
      );

      if (activeFetchId != currentFetchId ||
          selectedCategory != currentCategory) {
        return;
      }

      if (isRefresh) {
        courses.clear();
        courseIds.clear();
      }

      for (var course in fetchedCourses) {
        if (!courseIds.contains(course.id)) {
          courses.add(course);
          courseIds.add(course.id);
        }
      }

      hasMoreData = fetchedCourses.length >= limit;
      if (selectedCategory == currentCategory) {
        categoryCourseCache[selectedCategory] = List<CourseModel>.from(courses);
      }

      notifyListeners();
    } catch (error) {
      AppToastUtils.handleError(error, 'Error fetching courses');
    } finally {
      if (activeFetchId == currentFetchId) {
        categoryLoadingMap[selectedCategory] = false;
        isPaginating = false;
        notifyListeners();
      }
    }
  }

  void onTabTapped(int index) {
    if (tabController == null) return;
    String previousCategory = selectedCategory;
    selectedCategory = categories[index].id;

    // Reset the previous category's loading state
    categoryLoadingMap[previousCategory] = false;
    getCoursesByCategory(selectedCategory);
  }

  void getCoursesByCategory(String categoryId) {
    if (categoryLoadingMap[categoryId] == true) return;

    selectedCategory = categoryId;

    if (categoryCourseCache.containsKey(categoryId)) {
      courses = categoryCourseCache[categoryId]!;
      courseIds
          .addAll(categoryCourseCache[categoryId]!.map((course) => course.id));
      notifyListeners();
    } else {
      if (!isPaginating) {
        courses.clear();
        courseIds.clear();
        quizCounts.clear();
      }
      fetchCourses(isRefresh: true);
    }
  }

  Future<void> refreshCourses() async {
    final currentFetchId = DateTime.now().millisecondsSinceEpoch.toString();
    activeFetchId = currentFetchId;
    final currentCategory = selectedCategory;

    courses.clear();
    courseIds.clear();
    quizCounts.clear();
    _page = 1;

    await fetchCourses(isRefresh: true);

    if (activeFetchId != currentFetchId ||
        selectedCategory != currentCategory) {
      return;
    }

    courses.shuffle(Random());
    categoryCourseCache[selectedCategory] = List<CourseModel>.from(courses);
    notifyListeners();
  }
}
