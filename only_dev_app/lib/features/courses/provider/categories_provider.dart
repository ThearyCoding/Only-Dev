import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/category_model.dart';
import 'package:only_dev_app/service/firebase/firebase_api_categories.dart';

class CategoriesProvider extends ChangeNotifier {
  final FirebaseApiCategories _apiCategories = locator<FirebaseApiCategories>();

  List<CategoryModel> _categories = [];
  late StreamSubscription<List<CategoryModel>> _categorySubscription;
  bool _isLoading = false;
  bool _categoriesLoaded =
      false; // Flag to track if categories have been loaded

  // Getters
  bool get isLoading => _isLoading;
  List<CategoryModel> get categories => _categories;

  // Fetch categories when initializing
  CategoriesProvider() {
    if (!_categoriesLoaded) {
      _fetchCategories();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _fetchCategories() {
    setLoading(true);
    _categorySubscription = _apiCategories.getCategoriesStream().listen(
      (categoryList) {
        _categories = categoryList;
        setLoading(false);
        _categoriesLoaded = true; // Update flag when categories are loaded
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error fetching categories: $error');
        setLoading(false);
      },
    );
  }

  @override
  void dispose() {
    _categorySubscription.cancel();
    super.dispose();
  }
}
