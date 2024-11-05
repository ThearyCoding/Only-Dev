import 'dart:math';
import 'package:e_leaningapp/service/firebase/firebase_api_categories.dart';
import 'package:flutter/material.dart';
import '../di/dependency_injection.dart';
import '../export/export.dart';
import '../service/firebase/firebase_api_quiz.dart';
import '../utils/show_error_utils.dart';

class AllCoursesProvider with ChangeNotifier {
  final FirebaseApiQuiz _apiQuiz = locator<FirebaseApiQuiz>();
  List<CourseModel> courses = [];
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  TabController? tabController;
  String activeFetchId = '';
  bool isLoading = false;
  bool isPaginating = false;
  bool hasMoreData = true;
  Map<String, AdminModel> adminMap = {};
  Map<String, int> quizCounts = {};
  List<CourseModel> courseByCategoryId = [];
  User? user = FirebaseAuth.instance.currentUser;
  List<CategoryModel> categories = [];
  String selectedCategory = 'all';
  final int limit = 5;
  final FirebaseApiCategories _apiCategories = locator<FirebaseApiCategories>();
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
      List<CategoryModel> tempCategories =
          await _apiCategories.getCategories();
      tempCategories.insert(
          0, CategoryModel(id: 'all', title: 'All', imageUrl: ''));
      categories = tempCategories;

      tabController =
          TabController(length: categories.length, vsync: tickerProvider);
      // _refreshControllers =
      //     List.generate(categories.length, (_) => RefreshController());

      notifyListeners();
      fetchCourses();
    } catch (error) {
      handleError(error, 'Error fetching categories');
    }
  }

  Future<void> fetchCourses({
    bool isRefresh = false,
    bool isPagination = false,
  }) async {
    if (isLoading || isPaginating) return;

    if (isPagination) {
      isPaginating = true;
    } else {
      isLoading = true;
    }

    final currentFetchId = DateTime.now().millisecondsSinceEpoch.toString();
    activeFetchId = currentFetchId; // Set the current fetch ID
    final currentCategory = selectedCategory;

    try {
      QuerySnapshot<Map<String, dynamic>> courseSnapshot;

      if (isRefresh || courses.isEmpty) {
        // Fetching from the beginning or refreshing
        courseSnapshot = await _getCourseSnapshot();
        lastDocument =
            courseSnapshot.docs.isNotEmpty ? courseSnapshot.docs.last : null;
      } else {
        // Fetching more data (pagination)
        courseSnapshot = await _getCourseSnapshot(startAfter: lastDocument);
        lastDocument = courseSnapshot.docs.isNotEmpty
            ? courseSnapshot.docs.last
            : lastDocument;
      }

      // Convert documents to CourseModel
      final List<CourseModel> fetchedCourses = courseSnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data()))
          .toList();

      await Future.wait([
        fetchAdminData(),
        fetchQuizAndTotalLessons(fetchedCourses),
      ]);

      if (activeFetchId != currentFetchId ||
          selectedCategory != currentCategory) {
        return; // Cancel the operation if the category changed or another fetch started
      }

      if (isRefresh) {
        courses.clear();
        courseIds.clear();
        for (var course in fetchedCourses) {
          if (!courseIds.contains(course.id)) {
            courses.add(course);
            courseIds.add(course.id);
          }
        }
      } else {
        for (var course in fetchedCourses) {
          if (!courseIds.contains(course.id)) {
            courses.add(course);
            courseIds.add(course.id);
          }
        }
      }

      // Check if less than limit items were fetched, indicating no more data
      hasMoreData = fetchedCourses.length >= limit;
      if (!hasMoreData) {}

      if (selectedCategory == currentCategory) {
        categoryCourseCache[selectedCategory] = List<CourseModel>.from(courses);
      }

      notifyListeners();
    } catch (error) {
      handleError(error, 'Error fetching courses');
    } finally {
      if (activeFetchId == currentFetchId) {
        isLoading = false;
        isPaginating = false;
        notifyListeners();
      }
    }
  }

  void onTabTapped(int index) {
    if (tabController == null) return;
    selectedCategory = categories[index].id;
    getCoursesByCategory(categories[index].id);
  }

  void getCoursesByCategory(String categoryId) {
    if (isLoading) {
      if (categoryCourseCache.containsKey(selectedCategory)) {
        categoryCourseCache.remove(selectedCategory);
      }
    }

    selectedCategory = categoryId;

    if (categoryCourseCache.containsKey(categoryId)) {
      courses = categoryCourseCache[categoryId]!;
      courseIds
          .addAll(categoryCourseCache[categoryId]!.map((course) => course.id));
      notifyListeners(); // Notify listeners of state changesa
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
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
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
      QuerySnapshot adminSnapshot =
          await FirebaseFirestore.instance.collection('admins').get();
      Map<String, AdminModel> adminMapData = {
        for (var doc in adminSnapshot.docs)
          doc.id: AdminModel.fromJson(doc.data() as Map<String, dynamic>)
      };
      adminMap = adminMapData;
      notifyListeners();
    } catch (error) {
      handleError(error, 'Error fetching admin data');
    }
  }

  Future<void> fetchQuizAndTotalLessons(List<CourseModel> courseDocs) async {
    try {
      await Future.wait(courseDocs.map((course) async {
        String courseId = course.id;
        await fetchQuizCount(courseId);
      }));
    } catch (error) {
      handleError(error, 'Error fetching quiz and PDF counts');
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
