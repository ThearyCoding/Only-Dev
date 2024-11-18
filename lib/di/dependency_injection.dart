import 'package:e_leaningapp/service/shared/shared_preferences_service.dart';

import '../export/curriculum_export.dart';
import '../service/firebase/firebase_api_categories.dart';
import '../service/firebase/firebase_api_lecture.dart';
import 'package:get_it/get_it.dart';
import '../service/firebase/firebase_api_courses.dart';
import '../service/firebase/firebase_api_notifications.dart';
import '../service/firebase/firebase_api_quiz.dart';

final GetIt locator = GetIt.instance;

void setupLocator() async {
  // // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Firebase instances
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  locator
      .registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  locator.registerLazySingleton<FacebookAuth>(() => FacebookAuth.instance);

  // Register other services
  locator.registerLazySingleton(() => FirebaseApiRegistration());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => FirebaseApiNotifications());
  locator.registerLazySingleton(() => FirebaseApiQuiz());
  locator.registerLazySingleton(() => FirebaseApiCourses());
  locator.registerLazySingleton(() => FirebaseService());
  locator.registerLazySingleton(() => AuthServiceFacebook());
  locator.registerLazySingleton(() => AuthServiceGoogle());
  locator.registerLazySingleton(() => FirebaseApiLecture());
  locator.registerLazySingleton(() => FirebaseApiCategories());
  locator.registerLazySingleton(() => SharedPreferencesService());

  await locator.allReady();
}
