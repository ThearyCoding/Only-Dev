import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/category_Model.dart';

class CategoryPreferences {
  static const String _keyCategories = 'categories';

  static Future<void> saveCategories(List<CategoryModel> categories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = categories.map((category) => category.toJsonString()).toList();
    await prefs.setStringList(_keyCategories, jsonList);
  }

  static Future<List<CategoryModel>> loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_keyCategories);
    if (jsonList == null) {
      return [];
    }
    return jsonList.map((json) => CategoryModel.fromJsonString(json)).toList();
  }
}
