import 'dart:io';

class ApiEndpoints {
  // Base URLs:
  // On iOS Simulator & Desktop: localhost works directly.
  // On Android Emulator: 10.0.2.2 routes to the host machine.
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000/api/v1';
    }
    return 'http://localhost:4000/api/v1';
  }

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
  static String courseDetail(String id) => '/courses/$id';
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

