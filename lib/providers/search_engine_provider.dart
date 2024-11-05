import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/courses_model.dart';

class SearchEngineProvider with ChangeNotifier {
  String _txtSearch = '';
  List<CourseModel> _courses = [];
  bool _isLoading = false;
  bool _searchAttempted = false;

  String get txtSearch => _txtSearch;
  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  bool get searchAttempted => _searchAttempted;

  set txtSearch(String value) {
    _txtSearch = value;
    notifyListeners();
  }

  Future<void> searchCourses(String query) async {
    _isLoading = true;
    _searchAttempted = true;
    notifyListeners();

    try {
      String normalizedQuery = normalizeString(query);
      List<String> queryTokens = splitIntoTokens(normalizedQuery);

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('courses').get();

      _courses = querySnapshot.docs.where((doc) {
        String title = normalizeString(doc.get('title').toString());
        List<String> titleTokens = splitIntoTokens(title);

        // Check if any query token is in the title tokens
        return queryTokens.any((queryToken) =>
            titleTokens.any((titleToken) => titleToken.contains(queryToken)));
      }).map((doc) {
        return CourseModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Optional: Sort results by relevance
      _courses.sort((a, b) => calculateRelevance(b.title, queryTokens)
          .compareTo(calculateRelevance(a.title, queryTokens)));
    } catch (error) {
      log('Error fetching courses: $error');
      _courses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Normalize text by converting to lowercase and removing special characters
  String normalizeString(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '');
  }

  // Split the text into tokens (words)
  List<String> splitIntoTokens(String text) {
    return text.split(' ').where((token) => token.isNotEmpty).toList();
  }

  // Calculate relevance score based on token matches
  int calculateRelevance(String title, List<String> queryTokens) {
    List<String> titleTokens = splitIntoTokens(normalizeString(title));
    return queryTokens.fold<int>(
        0, (score, token) => score + (titleTokens.contains(token) ? 1 : 0));
  }

  void clearSearch() {
    _txtSearch = '';
    _courses = [];
    _isLoading = false;
    _searchAttempted = false;
    notifyListeners();
  }
}
