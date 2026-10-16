import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';

class CoursesViewModel extends BaseViewModel {
  final CourseRepository _courseRepository;

  List<CourseModel> _courses = [];
  List<CourseModel> get courses => _courses;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreCourses = true;
  bool get hasMoreCourses => _hasMoreCourses;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  CoursesViewModel(this._courseRepository);

  Future<void> fetchCourses({
    String? category,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreCourses = true;
    }
    if (category != null) {
      _selectedCategory = category;
    }

    setBusy(true);

    try {
      final results = await _courseRepository.getCourses(
        page: _currentPage,
        limit: _pageSize,
        category: _selectedCategory,
        search: search,
      );

      _courses = results;
      _hasMoreCourses = results.length >= _pageSize;
      setViewState(ViewState.success);
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> loadMoreCourses({String? search}) async {
    if (_isLoadingMore || !_hasMoreCourses) return false;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final results = await _courseRepository.getCourses(
        page: nextPage,
        limit: _pageSize,
        category: _selectedCategory,
        search: search,
      );

      if (results.isNotEmpty) {
        _currentPage = nextPage;
        _courses.addAll(results);
        _hasMoreCourses = results.length >= _pageSize;
        notifyListeners();
        return true;
      } else {
        _hasMoreCourses = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void filterByCategory(String? category) {
    if (_selectedCategory == category) return;
    fetchCourses(category: category, refresh: true);
  }
}

