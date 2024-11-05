import 'package:e_leaningapp/core/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../di/dependency_injection.dart';
import '../export/export.dart';
import '../model/notification_model.dart';
import '../service/firebase/firebase_api_notifications.dart';

class RegistrationProvider extends ChangeNotifier {
  final FirebaseApiRegistration _courseRegistrationService =
      locator<FirebaseApiRegistration>();
  final UserService userService = locator<UserService>();
  List<RegistrationModel> registeredCourses = [];
  final FirebaseApiNotifications _apiNotifications =
      locator<FirebaseApiNotifications>();
  Map<String, int> totalLecturesMap = {};
  Map<String, int> watchedLecturesMap = {};
  final User? user = locator<FirebaseAuth>().currentUser;
  bool hasShownDialog = false;
  bool isLoading = true;
  bool isCancelled = false;

  RegistrationProvider() {
    init();
  }

  Future<void> init() async {
    await fetchAllRegistrations(user!.uid);
  }

  Future<void> fetchAllRegistrations(String userId) async {
    try {
      final registrations =
          await _courseRegistrationService.getUserRegisteredCourses(userId);
      registeredCourses = registrations;

      // Concurrently fetch total lectures and watched lectures
      await Future.wait([
        _fetchTotalLecturesForCourses(),
        _fetchWatchedLecturesForCourses(),
      ]);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch registrations: $e');
      notifyListeners();
    }
  }

  Future<void> registerUser(
      String userId, String courseId, String categoryId, String title) async {
    if (isCancelled) {
      debugPrint('Registration cancelled.');
      return;
    }
    String registerId = const Uuid().v1();
    String notificationId = const Uuid().v1();
    await _courseRegistrationService.checkAndRegisterUser(
      userId: userId,
      courseId: courseId,
      categoryId: categoryId,
      id: registerId,
    );
    await _sendPushNotification(
      userId,
      title,
      "You have successfully registered for the course.",
      courseId,
      categoryId,
    );
    NotificationModel notification = NotificationModel(
      registerId: registerId,
      title: 'Registration Successful',
      message: 'You have successfully registered for the course: $title.',
      timestamp: DateTime.now(),
      courseId: courseId,
      id: notificationId,
      isRead: false,
      type: 'course',
      categoryId: categoryId,
    );

    await _apiNotifications.saveNotification(notification, userId);
    await fetchAllRegistrations(userId);
    hasShownDialog = false;
    notifyListeners();
  }

  Future<void> _sendPushNotification(String userId, String title, String body,
      String courseId, String categoryId) async {
    try {
      final response = await http.post(
        Uri.parse('$renderUrl/api/notifications/send-notification'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'uid': userId,
          'title': title,
          'body': body,
          'courseId': courseId,
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');
      } else {
        debugPrint('Failed to send notification');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to send notification: $e');
    }
  }

  bool isUserRegisteredForCourse(String courseId) {
    return registeredCourses.any((course) => course.courseId == courseId);
  }

  Future<void> _fetchTotalLecturesForCourses() async {
    Map<String, int> totalLectures = {};
    List<Future<void>> fetchTasks = [];
    for (var course in registeredCourses) {
      fetchTasks.add(
        userService
            .getTotalLectures(course.categoryId, course.courseId)
            .then((lectures) {
          totalLectures[course.courseId] = lectures;
        }),
      );
    }
    await Future.wait(fetchTasks);
    totalLecturesMap = totalLectures;
    notifyListeners();
  }

  Future<void> _fetchWatchedLecturesForCourses() async {
    Map<String, int> watchedLectures = {};
    List<Future<void>> fetchTasks = [];
    for (var course in registeredCourses) {
      fetchTasks.add(
        userService
            .getWatchedLecturesForCourse(course.courseId)
            .then((watchedData) {
          int watchedLessons = watchedData.values
              .map((sections) =>
                  (sections as Map<String, dynamic>).values.length)
              .fold(0, (prev, curr) => prev + curr);
          watchedLectures[course.courseId] = watchedLessons;
        }),
      );
    }
    await Future.wait(fetchTasks);
    watchedLecturesMap = watchedLectures;
    notifyListeners();
  }
}
