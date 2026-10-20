import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/data/repositories/quiz_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/lecture_model.dart';
import 'package:only_dev_app/model/section_model.dart';
import 'package:only_dev_app/service/shared/shared_preferences_service.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';

class LectureProvider with ChangeNotifier {
  final QuizRepository _quizRepository = locator<QuizRepository>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  int _selectedVideoIndex = 0;
  String _selectedLectureId = '';
  String _videoTitle = '';
  String _videoDescription = '';
  String _timestamp = '';
  bool _loadingQuestions = false;
  int _views = 0;
  int _totalQuestions = 0;
  bool _isLoading = false;
  bool _hasFetchedQuestions = false;
  User? user = locator<FirebaseAuth>().currentUser;
  List<Section> sections = [];
  int? lastWatchedSectionIndex;
  int? lastWatchedLectureIndex;
  Map<String, dynamic> watchedLectures = {};

  int get selectedIndexVideo => _selectedVideoIndex;
  String get videoTitle => _videoTitle;
  String get videoDescription => _videoDescription;
  String get timestamp => _timestamp;
  String get createdAt => _timestamp;
  int get views => _views;
  int get totalQuestions => _totalQuestions;
  bool get isLoading => _isLoading;
  String get selectedLectureId => _selectedLectureId;
  bool get loadingQuestions => _loadingQuestions;
  bool get hasFetchedQuestions => _hasFetchedQuestions;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoadingQuestions(bool value) {
    _loadingQuestions = value;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedVideoIndex = index;
    notifyListeners();
  }

  void setSelectedLectureId(String lectureId) {
    _selectedLectureId = lectureId;
    notifyListeners();
  }

  void setCurrentPlayingVideo(
    String videoTitle,
    String description,
    String timestamp,
    int views,
  ) {
    _videoTitle = videoTitle;
    _videoDescription = description;
    _timestamp = timestamp;
    _views = views;
    notifyListeners();
  }

  Future<void> fetchTotalQuestions(String courseId) async {
    if (_hasFetchedQuestions) return;
    setLoadingQuestions(true);

    try {
      _totalQuestions = await _quizRepository.fetchTotalQuestions(courseId);
    } catch (e) {
      AppToastUtils.error("Error fetching questions: $e");
    } finally {
      setLoadingQuestions(false);
      _hasFetchedQuestions = true;
    }
  }

  Future<void> getSections(String categoryId, String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final course = await _courseRepository.getCourseById(courseId);
      sections = course.sections ?? [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadLastWatchedLecture(String courseId) async {
    Map<String, dynamic>? savedData =
        await SharedPreferencesService().getSectionExpanded(courseId);

    if (savedData != null) {
      lastWatchedSectionIndex = savedData['sectionIndex'];
      lastWatchedLectureIndex = savedData['lectureIndex'];
    } else {
      lastWatchedSectionIndex = null;
      lastWatchedLectureIndex = null;
    }
    notifyListeners();
  }

  Future<void> saveSectionExpanded(
    String courseId,
    int sectionIndex,
    int lectureIndex,
  ) async {
    Section section = sections[sectionIndex];
    Lecture lecture = section.lectures[lectureIndex];

    await SharedPreferencesService().saveSectionExpanded(
      courseId,
      section.id,
      sectionIndex,
      lecture.id,
      lectureIndex,
    );
    lastWatchedSectionIndex = sectionIndex;
    lastWatchedLectureIndex = lectureIndex;
    notifyListeners();
  }

  Future<void> loadWatchedLectures() async {
    // In-memory / repository backed
    notifyListeners();
  }

  bool isLectureWatched(
    String courseId,
    int sectionIndex,
    int lectureIndex,
  ) {
    String sectionKey = sections[sectionIndex].id;
    String lectureKey = sections[sectionIndex].lectures[lectureIndex].id;

    return watchedLectures[courseId]?[sectionKey]?[lectureKey] ?? false;
  }

  bool isSectionExpanded(int sectionIndex) {
    return sectionIndex == lastWatchedSectionIndex;
  }
}
