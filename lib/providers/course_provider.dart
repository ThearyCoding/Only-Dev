import 'dart:developer';
import 'package:e_leaningapp/service/firebase/firebase_api_lecture.dart';
import '../export/export.dart';
import '../service/firebase/firebase_api_courses.dart';

class CourseProvider extends ChangeNotifier {
  final FirebaseApiQuiz _apiQuiz = locator<FirebaseApiQuiz>();
  final FirebaseApiCourses _apiCourses = locator<FirebaseApiCourses>();
  final FirebaseApiLecture _apiLecture = locator<FirebaseApiLecture>();
  List<CourseModel> _courses = [];
  final List<CourseModel> _courseByCategoryId = [];
  final Map<String, int> _quizCounts = {};
  List<CourseModel> _recentCourses = [];
  List<CourseModel> _popularCourses = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMoreCourses = true;
  bool _isLoading = false;
  bool _isLoadingCourseByCategoryId = false;
  bool _isLoadingRecentCourses = false;
  bool _isLoadingPopularCourses = false;
  CourseModel? _course;
  AdminModel? _admin;
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
  AdminModel? get admin => _admin;
  bool get isLoadingCourseDetail => _isLoadingCourseDetail;
  bool get isLoadingCourseByCategoryId => _isLoadingCourseByCategoryId;
  String? get firstVideoUrl => _firstVideoUrl;
  bool get isLoadingFirstVideo => _isLoadingFirstVideo;
  DocumentSnapshot? get snapshot => _lastDocument;

  bool get isLoadingRecentCourses => _isLoadingRecentCourses;
  bool get isLoadingPopularCourses => _isLoadingPopularCourses;

  Map<String, int> totalLecturesMap = {};
  Map<String, int> get lecturesMap => totalLecturesMap;

  Future<void> fetchQuizCount(String courseId) async {
    try {
      int count = await _apiQuiz.fetchTotalQuestions(courseId);
      _quizCounts[courseId] = count;
      notifyListeners();
    } catch (error) {
      log('Error fetching quiz count: $error');
    }
  }

void fetchRecentCourses() {
  if (_hasFetchedRecentCourses) return;  

  setLoadingRecentCourses(true);

  try {
    FirebaseFirestore.instance
        .collectionGroup('courses')
        .where('status', whereIn: ['active', 'inactive'])
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((courseQuery) {
          _recentCourses = courseQuery.docs
              .map((doc) => CourseModel.fromMap(doc.data()))
              .toList();

          fetchTotalLecturesForRecentCourses();
          setLoadingRecentCourses(false);

          _hasFetchedRecentCourses = true;
          notifyListeners();
        });
  } catch (e) {
    log('Error fetching recent courses: $e');
    setLoadingRecentCourses(false);
  }
}


  void fetchPopularCourses() {
  if (_hasFetchedPopularCourses) return; 
  setLoadingPopularCourses(true);

  try {
    FirebaseFirestore.instance
        .collectionGroup('courses')
        .where('status', whereIn: ['active', 'inactive'])
        .orderBy('registerCounts', descending: true)
        .limit(10)
        .snapshots()
        .listen((courseQuery) {
          _popularCourses = courseQuery.docs
              .map((doc) => CourseModel.fromMap(doc.data()))
              .toList();

          fetchTotalLecturesForPopularCourses();
          setLoadingPopularCourses(false);

          _hasFetchedPopularCourses = true;
          notifyListeners();
        });
  } catch (e) {
    log('Error fetching popular courses: $e');
    setLoadingPopularCourses(false);
  }
}


  Future<void> fetchCourses() async {
    try {
      setLoading(true);
      _apiCourses.fetchCourses().listen((fetchedCourses) async {
        _courses = fetchedCourses;
        _courses
            .shuffle(); 
        await Future.wait(_courses.map((course) async {
          await fetchQuizCount(course.id);
        }));

        await fetchTotalLecturesForAllCourses();

        setLoading(false);
      });
    } catch (e) {
      log('Error fetching courses: $e');
      setLoading(false);
    }
  }

  void clearCoursesByCategoryId() {
    _lastDocument = null;
    _courseByCategoryId.clear();
    _hasMoreCourses = true;
    notifyListeners();
  }

  Future<void> getCoursesByCategory(String categoryId,
      {bool isRefresh = false}) async {
    if (_isLoadingCourseByCategoryId) return;

    setLoadingCoursebyCategoryId(true);

    if (isRefresh) {
      _lastDocument = null;
      _courseByCategoryId.clear();
      _hasMoreCourses = true;
      notifyListeners();
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .orderBy('timestamp')
          .limit(4);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot courseSnapshot = await query.get();

      if (courseSnapshot.docs.isNotEmpty) {
        _lastDocument = courseSnapshot.docs.last;

        final newCourses = courseSnapshot.docs.map((doc) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            return CourseModel.fromMap(data);
          } else {
            throw Exception('Unexpected data format');
          }
        }).toList();

        _courseByCategoryId.addAll(newCourses);
        _hasMoreCourses = newCourses.length == 4;
      } else {
        _hasMoreCourses = false;
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
      fetchCourses();
      await Future.wait(_courses.map((course) async {
        await fetchQuizCount(course.id);
      }));
      setLoading(false);
    } catch (e) {
      log('Error refreshing courses: $e');
      setLoading(false);
    }
  }

  Future<void> fetchCourseAndAdminById(
      String categoryId, String courseId) async {
    try {
      setLoadingCourseDetail(true);
      final data = await _apiCourses.fetchCourseAndAdminById(
        categoryId: categoryId,
        courseId: courseId,
      );

      if (data != null) {
        _course = data['course'] as CourseModel;
        _admin = data['admin'] as AdminModel;
      } else {
        _course = null;
        _admin = null;
      }
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
      final videoUrl =
          await _apiLecture.fetchFirstVideoUrl(categoryId, courseId);
      _firstVideoUrl = videoUrl;
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
    setLoading(true);
    notifyListeners();

    Map<String, int> fetchedTotalLectures = {};
    List<Future<void>> fetchTasks = [];

    for (var course in _courses) {
      fetchTasks.add(
        _apiLecture
            .getTotalLectures(course.categoryId, course.id)
            .then((lectures) {
          fetchedTotalLectures[course.id] = lectures;
        }),
      );
    }

    await Future.wait(fetchTasks);
    totalLecturesMap = fetchedTotalLectures;
    setLoading(false);
    notifyListeners();
  }

  // Fetch total lectures for recent courses
  Future<void> fetchTotalLecturesForRecentCourses() async {
    setLoadingRecentCourses(true);
    notifyListeners();

    Map<String, int> fetchedTotalLectures = {};
    List<Future<void>> fetchTasks = [];

    for (var course in _recentCourses) {
      fetchTasks.add(
        _apiLecture
            .getTotalLectures(course.categoryId, course.id)
            .then((lectures) {
          fetchedTotalLectures[course.id] = lectures;
        }),
      );
    }

    await Future.wait(fetchTasks);
    totalLecturesMap.addAll(fetchedTotalLectures);

    setLoadingRecentCourses(false);
    notifyListeners();
  }

  // Fetch total lectures for popular courses
  Future<void> fetchTotalLecturesForPopularCourses() async {
    setLoadingPopularCourses(true);
    notifyListeners();

    Map<String, int> fetchedTotalLectures = {};
    List<Future<void>> fetchTasks = [];

    for (var course in _popularCourses) {
      fetchTasks.add(
        _apiLecture
            .getTotalLectures(course.categoryId, course.id)
            .then((lectures) {
          fetchedTotalLectures[course.id] = lectures;
        }),
      );
    }

    await Future.wait(fetchTasks);
    totalLecturesMap.addAll(fetchedTotalLectures);

    setLoadingPopularCourses(false);
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
