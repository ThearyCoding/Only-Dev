import 'package:e_leaningapp/service/firebase/firebase_api_section.dart';

import '../export/export.dart';

class LectureProvider with ChangeNotifier {
  final FirebaseApiQuiz _apiQuiz = locator<FirebaseApiQuiz>();
  final FirebaseApiSection _apiSection = locator<FirebaseApiSection>();
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
      _totalQuestions = await _apiQuiz.fetchTotalQuestions(courseId);
    } catch (e) {
      showSnackbar("Error fetching questions: $e");
    } finally {
      setLoadingQuestions(false);
      _hasFetchedQuestions = true;
    }
  }

  Future<void> getSections(String categoryId, String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<Section> tempSections =
          await _apiSection.fetchSections(categoryId, courseId);
      sections = tempSections;

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
    watchedLectures = await UserService().getWatchedLectures();
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
