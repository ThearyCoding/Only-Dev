import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/section_model.dart';
import '../service/firebase/firebase_api_quiz.dart';
import '../service/firebase/firebase_api_user.dart';
import '../service/shared/shared_preferences_service.dart';

class LectureProvider with ChangeNotifier {
  final FirebaseApiQuiz _apiQuiz = locator<FirebaseApiQuiz>();
  final FirebaseFirestore _firestore = locator<FirebaseFirestore>();
  int _selectedVideoIndex = 0;
  String _selectedLectureId = '';
  String _videoTitle = '';
  String _videoDescription = '';
  String _timestamp = '';
  bool _loadingquestions = false;
  int _views = 0;
  bool _isExpanded = false;
  int _totalQuestions = 0;
  bool _isLoading = false;
  bool _hasFetchedQuestions = false;
  User? user = locator<FirebaseAuth>().currentUser;
  List<Section> sections = [];
  String? lastWatchedSectionId;
  String? lastWatchedLectureId;
  Map<String, dynamic> watchedLectures = {};

  int get selectedIndexVideo => _selectedVideoIndex;
  String get videoTitle => _videoTitle;
  String get videoDescription => _videoDescription;
  String get timestamp => _timestamp;
  int get views => _views;
  bool get isExpanded => _isExpanded;
  int get totalQuestions => _totalQuestions;
  bool get isLoading => _isLoading;
  String get selectedLectureId => _selectedLectureId;
  bool get loadingquestion => _loadingquestions;
  bool get hasFetchedQuestions => _hasFetchedQuestions;
  void setLoading(bool value) {
    _isLoading = value; // Set value to update observable
  }

  void setLoadingquestion(bool value) {
    _loadingquestions = value;
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
      String videoTitle, String description, String timestamp, int views) {
    _videoTitle = videoTitle;
    _videoDescription = description;
    _timestamp = timestamp;
    _views = views;
    notifyListeners();
  }

  void toggleExpansion() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  Future<void> fetchTotalQuestions(String courseId) async {
    if (_hasFetchedQuestions) return;
    setLoadingquestion(true);
    notifyListeners();

    try {
      _totalQuestions = await _apiQuiz.fetchTotalQuestions(courseId);
    } catch (e) {
      showSnackbar("Error fetching questions : $e");
    } finally {
      setLoadingquestion(false);
      notifyListeners();
      _hasFetchedQuestions = true;
    }
  }

  Future<void> getSections(String categoryId, String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<Section> tempSections = await fetchSections(categoryId, courseId);
      sections = tempSections;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Section>> fetchSections(
      String categoryId, String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('sections')
          .get();

      return querySnapshot.docs
          .map((doc) => Section.fromFirestore(doc))
          .toList();
    } catch (error) {
      log('Error fetching section: $error');
      return [];
    }
  }

  Future<void> loadLastWatchedLecture(String courseId) async {
    List<String>? savedData =
        await SharedPreferencesService().getSectionExpanded(courseId);

    if (savedData != null && savedData.length == 2) {
      lastWatchedSectionId = savedData[0];
      lastWatchedLectureId = savedData[1];
    } else {
      lastWatchedSectionId = null;
      lastWatchedLectureId = null;
    }
    notifyListeners();
  }

  Future<void> loadWatchedLectures() async {
    watchedLectures = await UserService().getWatchedLectures();
    notifyListeners();
  }

  bool isLectureWatched(String courseId, String sectionId, String lectureId) {
    if (watchedLectures.containsKey(courseId)) {
      final courseData = watchedLectures[courseId];
      if (courseData.containsKey(sectionId)) {
        return courseData[sectionId][lectureId] == true;
      }
    }
    return false;
  }

  Future<void> saveSectionExpanded(
      String courseId, String sectionId, String lectureId) async {
    await SharedPreferencesService()
        .saveSectionExpanded(courseId, sectionId, lectureId);
    lastWatchedSectionId = sectionId;
    lastWatchedLectureId = lectureId;
    notifyListeners();
  }

  bool isSectionExpanded(String sectionId) {
    return sectionId == lastWatchedSectionId;
  }
}
