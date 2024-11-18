import 'dart:math';
import 'package:e_leaningapp/service/firebase/firebase_api_categories.dart';
import 'package:flutter/material.dart';
import '../di/dependency_injection.dart';
import '../export/export.dart';
import '../service/firebase/firebase_api_quiz.dart';
import '../utils/show_error_utils.dart';

class AllCoursesProvider with ChangeNotifier {
  final FirebaseApiQuiz _apiQuiz = locator<FirebaseApiQuiz>();
  final FirebaseApiCategories _apiCategories = locator<FirebaseApiCategories>();
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();

  List<CourseModel> courses = [];
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  TabController? tabController;
  String activeFetchId = '';
  bool isLoadingCategories = false;
  bool isPaginating = false;
  bool hasMoreData = true;
  Map<String, AdminModel> adminMap = {};
  Map<String, int> quizCounts = {};
  Map<String, bool> categoryLoadingMap =
      {}; // Map for each category's loading status
  List<CourseModel> courseByCategoryId = [];
  User? user = locator<FirebaseAuth>().currentUser;
  List<CategoryModel> categories = [];
  String selectedCategory = 'all';
  final int limit = 5;
  final Set<String> courseIds = <String>{};
  final Map<String, List<CourseModel>> categoryCourseCache = {};

  AllCoursesProvider({required TickerProvider tickerProvider}) {
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
      List<CategoryModel> tempCategories = await _apiCategories.getCategories();
      tempCategories.insert(
          0, CategoryModel(id: 'all', title: 'All', imageUrl: ''));
      categories = tempCategories;

      tabController =
          TabController(length: categories.length, vsync: tickerProvider);
      for (var category in categories) {
        categoryLoadingMap[category.id] =
            false; // Initialize loading status for each category
      }

      notifyListeners();
      fetchCourses();
    } catch (error) {
      handleError(error, 'Error fetching categories');
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
      QuerySnapshot<Map<String, dynamic>> courseSnapshot;

      if (isRefresh || courses.isEmpty) {
        courseSnapshot = await _getCourseSnapshot();
        lastDocument =
            courseSnapshot.docs.isNotEmpty ? courseSnapshot.docs.last : null;
      } else {
        courseSnapshot = await _getCourseSnapshot(startAfter: lastDocument);
        lastDocument = courseSnapshot.docs.isNotEmpty
            ? courseSnapshot.docs.last
            : lastDocument;
      }

      final List<CourseModel> fetchedCourses = courseSnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data()))
          .toList();

      await Future.wait([
        fetchAdminData(),
        if (fetchedCourses.isNotEmpty) fetchQuizCount(fetchedCourses.first.id),
      ]);

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
      handleError(error, 'Error fetching courses');
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

  Future<QuerySnapshot<Map<String, dynamic>>> _getCourseSnapshot({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collectionGroup('courses')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (selectedCategory != 'all') {
      query = query.where('categoryId', isEqualTo: selectedCategory);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<void> fetchAdminData() async {
    try {
      QuerySnapshot adminSnapshot = await _firestore.collection('admins').get();
      adminMap = {
        for (var doc in adminSnapshot.docs)
          doc.id: AdminModel.fromJson(doc.data() as Map<String, dynamic>)
      };
      notifyListeners();
    } catch (error) {
      handleError(error, 'Error fetching admin data');
    }
  }

  Future<void> fetchQuizCount(String courseId) async {
    try {
      int quizCount = await _apiQuiz.fetchTotalQuestions(courseId);
      quizCounts[courseId] = quizCount;
      notifyListeners();
    } catch (error) {
      handleError(error, 'Error fetching quiz count');
    }
  }

  Future<void> refreshCourses() async {
    final currentFetchId = DateTime.now().millisecondsSinceEpoch.toString();
    activeFetchId = currentFetchId;
    final currentCategory = selectedCategory;

    courses.clear();
    courseIds.clear();
    quizCounts.clear();
    lastDocument = null;

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
