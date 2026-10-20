import '../../service/api/api_endpoints.dart';
import '../../service/api/dio_client.dart';

abstract class QuizRemoteDataSource {
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId);
  Future<Map<String, dynamic>> getQuizDetail(String quizId);
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final DioClient _dioClient;

  QuizRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId) async {
    final response = await _dioClient.get(ApiEndpoints.quizzesByCourse(courseId));
    if (response.data != null && response.data['data'] != null) {
      final list = response.data['data'] as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    final response = await _dioClient.get(ApiEndpoints.quizDetail(quizId));
    if (response.data != null && response.data['data'] != null) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load quiz detail');
  }

  @override
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data) async {
    final response = await _dioClient.post(
      ApiEndpoints.submitQuiz(quizId),
      data: data,
    );
    if (response.data != null && response.data['data'] != null) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to submit quiz attempt');
  }
}
