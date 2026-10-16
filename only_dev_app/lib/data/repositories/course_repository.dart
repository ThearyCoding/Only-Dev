import '../datasources/course_remote_data_source.dart';
import '../models/models.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  });

  Future<CourseModel> getCourseById(String id);
}

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remoteDataSource;

  CourseRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? search,
  }) {
    return _remoteDataSource.getCourses(
      page: page,
      limit: limit,
      category: category,
      level: level,
      search: search,
    );
  }

  @override
  Future<CourseModel> getCourseById(String id) {
    return _remoteDataSource.getCourseById(id);
  }
}

