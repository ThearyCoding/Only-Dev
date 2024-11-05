import 'dart:developer';
import 'package:e_leaningapp/service/firebase/firebase_api_lecture.dart';

import '../di/dependency_injection.dart';
import '../export/export.dart';
import '../service/firebase/firebase_api_courses.dart';
import '../service/firebase/firebase_api_quiz.dart';
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

  CourseModel? _course;
  AdminModel? _admin;
  bool _isLoadingCourseDetail = false;
  
  bool _hasFetchedRecentCourses = false;
  bool _hasFetchedPopularCourses = false;
  
  String? _firstVideoUrl; // New variable to store the first video URL
  bool _isLoadingFirstVideo = false; // New variable to manage loading state

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
  
  CourseProvider() {
    fetchCourses();
  }
  

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

    setLoading(true);

    try {
      FirebaseFirestore.instance
          .collectionGroup('courses')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots()
          .listen((courseQuery) {
        _recentCourses = courseQuery.docs
            .map((doc) => CourseModel.fromMap(doc.data()))
            .toList();
        setLoading(false);
        _hasFetchedRecentCourses = true;
      });
    } catch (e) {
      log('Error fetching recent courses: $e');
      setLoading(false);
    }
  }

  void fetchPopularCourses() {
    if (_hasFetchedPopularCourses) return;

    setLoading(true);

    try {
      FirebaseFirestore.instance
          .collectionGroup('courses')
          .orderBy('registerCounts', descending: true)
          .limit(10)
          .snapshots()
          .listen((courseQuery) {
        _popularCourses = courseQuery.docs
            .map((doc) => CourseModel.fromMap(doc.data()))
            .toList();
        setLoading(false);
        _hasFetchedPopularCourses = true;
      });
    } catch (e) {
      log('Error fetching popular courses: $e');
      setLoading(false);
      rethrow;
    }
  }

  void fetchCourses() async {
    try {
      setLoading(true);
      _apiCourses.fetchCourses().listen((fetchedCourses) async {
        _courses = fetchedCourses;
        _courses.shuffle();
        await Future.wait(_courses.map((course) async {
          await fetchQuizCount(course.id);
        }));
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

  Future<void> getCoursesByCategory(String categoryId, {bool isRefresh = false}) async {
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

  Future<void> fetchCourseAndAdminById(String categoryId, String courseId) async {
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
      final videoUrl = await _apiLecture.fetchFirstVideoUrl(categoryId, courseId);
      _firstVideoUrl = videoUrl;
      notifyListeners();
    } catch (e) {
      log('Error fetching first video URL: $e');
      _firstVideoUrl = null;
    } finally {
      setLoadingFirstVideo(false);
    }
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
}