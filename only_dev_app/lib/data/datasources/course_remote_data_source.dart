import '../../service/api/api_endpoints.dart';
import '../../service/api/dio_client.dart';
import '../models/models.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  });

  Future<CourseModel> getCourseById(String id);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final DioClient _dioClient;

  CourseRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.courses,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null && category.isNotEmpty) 'category': category,
        if (level != null && level.isNotEmpty) 'level': level,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      final coursesData = response.data['data']['courses'] as List? ?? [];
      return coursesData
          .map((item) => CourseModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    final response = await _dioClient.get(ApiEndpoints.courseDetail(id));
    if (response.data != null && response.data['data'] != null) {
      return CourseModel.fromMap(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load course details');
  }
}

