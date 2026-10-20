import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/home/repository/home_repository.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/model/courses_model.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';

class CourseProvider extends ChangeNotifier {
  final HomeRepository _homeRepository = locator<HomeRepository>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final QuizRepository _quizRepository = locator<QuizRepository>();
  List<CourseModel> _courses = [];
  final List<CourseModel> _courseByCategoryId = [];
  final Map<String, int> _quizCounts = {};
  List<CourseModel> _recentCourses = [];
  List<CourseModel> _popularCourses = [];
  int _categoryPage = 1;
  bool _hasMoreCourses = true;
  bool _isLoading = false;
  bool _isLoadingCourseByCategoryId = false;
  bool _isLoadingRecentCourses = false;
  bool _isLoadingPopularCourses = false;
  CourseModel? _course;
  UserModel? _admin;
  bool _isLoadingCourseDetail = false;
  String? _firstVideoUrl;
  bool _isLoadingFirstVideo = false;
  bool _hasFetchedPopularCourses = false;
  bool _hasFetchedRecentCourses = false;
  // Getters
  List<CourseModel> get courses => _courses;
  List<CourseModel> get courseByCategoryId => _courseByCategoryId;
  Map<String, int> get quizCounts => _quizCounts;
  List<CourseModel> get recentCourses => _recentCourses;
  List<CourseModel> get popularCourses => _popularCourses;
  bool get isLoading => _isLoading;
  bool get hasFetchedRecentCourses => _hasFetchedRecentCourses;
  bool get hasFetchedPopularCourses => _hasFetchedPopularCourses;
  bool get hasMoreCourses => _hasMoreCourses;
  CourseModel? get course => _course;
  UserModel? get admin => _admin;
  bool get isLoadingCourseDetail => _isLoadingCourseDetail;
  bool get isLoadingCourseByCategoryId => _isLoadingCourseByCategoryId;
  String? get firstVideoUrl => _firstVideoUrl;
  bool get isLoadingFirstVideo => _isLoadingFirstVideo;
  bool get isLoadingRecentCourses => _isLoadingRecentCourses;
  bool get isLoadingPopularCourses => _isLoadingPopularCourses;

  Map<String, int> totalLecturesMap = {};
  Map<String, int> get lecturesMap => totalLecturesMap;

  Future<void> fetchQuizCount(String courseId) async {
    try {
      int count = await _quizRepository.fetchTotalQuestions(courseId);
      _quizCounts[courseId] = count;
      notifyListeners();
    } catch (error) {
      log('Error fetching quiz count: $error');
    }
  }

  Future<void> fetchRecentCourses() async {
    if (_hasFetchedRecentCourses) return;  
    setLoadingRecentCourses(true);

    try {
      final homeData = await _homeRepository.getHomeScreenData();
      _recentCourses = homeData.recentCourses;
      _hasFetchedRecentCourses = true;
    } catch (e) {
      log('Error fetching recent courses: $e');
    } finally {
      setLoadingRecentCourses(false);
      notifyListeners();
    }
  }

  Future<void> fetchPopularCourses() async {
    if (_hasFetchedPopularCourses) return; 
    setLoadingPopularCourses(true);

    try {
      final homeData = await _homeRepository.getHomeScreenData();
      _popularCourses = homeData.popularCourses;
      _hasFetchedPopularCourses = true;
    } catch (e) {
      log('Error fetching popular courses: $e');
    } finally {
      setLoadingPopularCourses(false);
      notifyListeners();
    }
  }

  Future<void> fetchCourses() async {
    setLoading(true);
    try {
      final homeData = await _homeRepository.getHomeScreenData();
      _courses = homeData.courses;
    } catch (e) {
      log('Error fetching courses: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void clearCoursesByCategoryId() {
    _categoryPage = 1;
    _courseByCategoryId.clear();
    _hasMoreCourses = true;
    notifyListeners();
  }

  Future<void> getCoursesByCategory(String categoryId,
      {bool isRefresh = false}) async {
    if (_isLoadingCourseByCategoryId) return;

    setLoadingCoursebyCategoryId(true);

    if (isRefresh) {
      _categoryPage = 1;
      _courseByCategoryId.clear();
      _hasMoreCourses = true;
      notifyListeners();
    }

    try {
      final results = await _courseRepository.getCourses(
        page: _categoryPage,
        limit: 20,
        category: categoryId,
      );

      _courseByCategoryId.addAll(results);
      _hasMoreCourses = results.length >= 20;
      if (_hasMoreCourses) {
        _categoryPage++;
      }
      notifyListeners();
    } catch (error) {
      log('Error fetching courses by category: $error');
      _hasMoreCourses = false;
    } finally {
      setLoadingCoursebyCategoryId(false);
    }
  }

  Future<void> refreshCourses() async {
    try {
      setLoading(true);
      final homeData = await _homeRepository.getHomeScreenData();
      _courses = homeData.courses;
      _recentCourses = homeData.recentCourses;
      _popularCourses = homeData.popularCourses;
    } catch (e) {
      log('Error refreshing courses: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchCourseAndAdminById(
      String categoryId, String courseId) async {
    try {
      setLoadingCourseDetail(true);
      final course = await _courseRepository.getCourseById(courseId);
      _course = course;
      _admin = course.instructor;
      notifyListeners();
    } catch (e) {
      log('Error fetching course and admin by ID: $e');
      _course = null;
      _admin = null;
    } finally {
      setLoadingCourseDetail(false);
    }
  }

  Future<void> getFirstVideoUrl(String categoryId, String courseId) async {
    if (_isLoadingFirstVideo) return;

    setLoadingFirstVideo(true);

    try {
      final course = await _courseRepository.getCourseById(courseId);
      if (course.sections != null && course.sections!.isNotEmpty) {
        for (final sec in course.sections!) {
          final firstWithVid =
              sec.lectures.where((l) => l.videoUrl.isNotEmpty).firstOrNull;
          if (firstWithVid != null) {
            _firstVideoUrl = firstWithVid.videoUrl;
            break;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      log('Error fetching first video URL: $e');
      _firstVideoUrl = null;
    } finally {
      setLoadingFirstVideo(false);
    }
  }

  // Fetch total lectures for all courses
  Future<void> fetchTotalLecturesForAllCourses() async {
    for (var course in _courses) {
      totalLecturesMap[course.id] = course.totalLessons ?? 0;
    }
    notifyListeners();
  }

  // Fetch total lectures for recent courses
  Future<void> fetchTotalLecturesForRecentCourses() async {
    for (var course in _recentCourses) {
      totalLecturesMap[course.id] = course.totalLessons ?? 0;
    }
    notifyListeners();
  }

  // Fetch total lectures for popular courses
  Future<void> fetchTotalLecturesForPopularCourses() async {
    for (var course in _popularCourses) {
      totalLecturesMap[course.id] = course.totalLessons ?? 0;
    }
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoadingCoursebyCategoryId(bool value) {
    _isLoadingCourseByCategoryId = value;
    notifyListeners();
  }

  void setLoadingCourseDetail(bool value) {
    _isLoadingCourseDetail = value;
    notifyListeners();
  }

  void setLoadingFirstVideo(bool value) {
    _isLoadingFirstVideo = value;
    notifyListeners();
  }

  void setLoadingRecentCourses(bool value) {
    _isLoadingRecentCourses = value;
    notifyListeners();
  }

  void setLoadingPopularCourses(bool value) {
    _isLoadingPopularCourses = value;
    notifyListeners();
  }
}
