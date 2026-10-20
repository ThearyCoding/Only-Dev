import 'package:only_dev_app/model/banner_model.dart';
import 'package:only_dev_app/model/category_model.dart';
import 'package:only_dev_app/model/courses_model.dart';

class HomeScreenData {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<CourseModel> courses;
  final List<CourseModel> recentCourses;
  final List<CourseModel> popularCourses;

  HomeScreenData({
    required this.banners,
    required this.categories,
    required this.courses,
    required this.recentCourses,
    required this.popularCourses,
  });

  factory HomeScreenData.fromJson(Map<String, dynamic> json) {
    final bannersList = (json['banners'] as List<dynamic>?)
            ?.map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final categoriesList = (json['categories'] as List<dynamic>?)
            ?.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final coursesList = (json['courses'] as List<dynamic>?)
            ?.map((item) => CourseModel.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [];

    final recentList = (json['recent_courses'] as List<dynamic>?)
            ?.map((item) => CourseModel.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [];

    final popularList = (json['popular_courses'] as List<dynamic>?)
            ?.map((item) => CourseModel.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [];

    return HomeScreenData(
      banners: bannersList,
      categories: categoriesList,
      courses: coursesList,
      recentCourses: recentList,
      popularCourses: popularList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banners': banners.map((b) => b.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'courses': courses.map((c) => c.toMap()).toList(),
      'recent_courses': recentCourses.map((c) => c.toMap()).toList(),
      'popular_courses': popularCourses.map((c) => c.toMap()).toList(),
    };
  }
}

