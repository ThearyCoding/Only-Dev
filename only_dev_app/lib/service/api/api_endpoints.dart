import '../../core/config/app_config.dart';

class ApiEndpoints {
  /// Base API URL dynamically provided by the active AppConfig environment
  static String get baseUrl => AppConfig.instance.apiBaseUrl;

  // Screen-Aggregated BFF Endpoints (Single Screen = Single Endpoint)
  static const String home = '/home';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String socialAuth = '/auth/social';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
  static const String userProfile = '/users/me';

  // Roles (Dynamic RBAC)
  static const String roles = '/roles';
  static const String availablePermissions = '/roles/permissions/available';

  // Courses
  static const String courses = '/courses';
  static String courseDetail(String id) => '/courses/get-detail/$id';
  static String courseSections(String id) => '/courses/$id/sections';
  static String sectionLessons(String sectionId) => '/courses/sections/$sectionId/lessons';

  // Enrollments
  static const String enrollments = '/enrollments';
  static const String myCourses = '/enrollments/my-courses';
  static String checkEnrollment(String courseId) => '/enrollments/check/$courseId';
  static String courseProgress(String courseId) => '/enrollments/progress/$courseId';

  // Quizzes
  static const String quizzes = '/quizzes';
  static String quizDetail(String id) => '/quizzes/$id';
  static String submitQuiz(String id) => '/quizzes/$id/submit';
  static String quizAttempts(String id) => '/quizzes/$id/attempts';
  static String quizzesByCourse(String courseId) => '/quizzes/course/$courseId';

  // Storage (Cloudflare R2)
  static const String presign = '/storage/presign';
}

