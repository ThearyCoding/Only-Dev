import 'package:flutter/foundation.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/home/repository/home_repository.dart';
import 'package:only_dev_app/model/category_model.dart';

class CategoriesProvider extends ChangeNotifier {
  final HomeRepository _homeRepository = locator<HomeRepository>();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _categoriesLoaded = false;

  bool get isLoading => _isLoading;
  List<CategoryModel> get categories => _categories;

  CategoriesProvider() {
    if (!_categoriesLoaded) {
      fetchCategories();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    setLoading(true);
    try {
      final homeData = await _homeRepository.getHomeScreenData();
      _categories = homeData.categories;
      _categoriesLoaded = true;
    } catch (error) {
      debugPrint('Error fetching categories from HomeRepository: $error');
    } finally {
      setLoading(false);
    }
  }
}
