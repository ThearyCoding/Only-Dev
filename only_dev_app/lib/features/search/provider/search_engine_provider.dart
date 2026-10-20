import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/courses_model.dart';

class SearchEngineProvider with ChangeNotifier {
  final CourseRepository _courseRepository = locator<CourseRepository>();

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
    if (query.trim().isEmpty) {
      _courses = [];
      _searchAttempted = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _searchAttempted = true;
    notifyListeners();

    try {
      _courses = await _courseRepository.getCourses(
        search: query.trim(),
        limit: 30,
      );
    } catch (error) {
      log('Error searching courses: $error');
      _courses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _txtSearch = '';
    _courses = [];
    _isLoading = false;
    _searchAttempted = false;
    notifyListeners();
  }
}
