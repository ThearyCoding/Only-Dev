import '../datasources/quiz_remote_data_source.dart';

abstract class QuizRepository {
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId);
  Future<Map<String, dynamic>> getQuizDetail(String quizId);
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data);
  Future<int> fetchTotalQuestions(String courseId);
}

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource _remoteDataSource;

  QuizRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> getQuizzesByCourse(String courseId) {
    return _remoteDataSource.getQuizzesByCourse(courseId);
  }

  @override
  Future<Map<String, dynamic>> getQuizDetail(String quizId) {
    return _remoteDataSource.getQuizDetail(quizId);
  }

  @override
  Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> data) {
    return _remoteDataSource.submitQuiz(quizId, data);
  }

  @override
  Future<int> fetchTotalQuestions(String courseId) async {
    try {
      final quizzes = await _remoteDataSource.getQuizzesByCourse(courseId);
      int total = 0;
      for (final quiz in quizzes) {
        final questions = quiz['questions'] as List? ?? [];
        total += questions.length;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}
