import '../export/curriculum_export.dart';
import '../service/firebase/firebase_api_categories.dart';
import '../service/firebase/firebase_api_lecture.dart';
import 'package:get_it/get_it.dart';
import '../service/firebase/firebase_api_courses.dart';
import '../service/firebase/firebase_api_notifications.dart';
import '../service/firebase/firebase_api_quiz.dart';

final GetIt locator = GetIt.instance;

// will pass TickerProvider tickerProvider in function setLocator
void setupLocator() async {

  
  // Register services and providers
  // locator.registerLazySingleton(() => AuthenticationProvider());
  // locator.registerLazySingleton(() => UserProvider(locator(), locator));
  // locator.registerLazySingleton(() => LectureProvider());
  // locator.registerLazySingleton(() => CourseProvider());
  // locator.registerLazySingleton(() => AdminProvider());
  // locator.registerLazySingleton(() => CategoriesProvider());
  // locator.registerLazySingleton(() => CustomizeThemeProvider());
  // locator.registerLazySingleton(() => NotificationProvider());
  // locator.registerFactory(() => AllCoursesProvider(tickerProvider: locator));
  // locator.registerLazySingleton(() => SearchEngineProvider());
  // locator.registerLazySingleton(() => BannersProvider());

  // // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Firebase instances
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  locator.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

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

  await locator.allReady();
}
