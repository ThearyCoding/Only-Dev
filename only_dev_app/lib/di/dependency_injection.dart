
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../messaging/local_notification_service.dart';
import '../service/firebase/auth_service_google.dart';
import '../service/firebase/firebase_api_categories.dart';
import '../service/firebase/firebase_api_courses.dart';
import '../service/firebase/firebase_api_lecture.dart';
import '../service/firebase/firebase_api_notifications.dart';
import '../service/firebase/firebase_api_quiz.dart';
import '../service/firebase/firebase_api_registration.dart';
import '../service/firebase/firebase_api_section.dart';
import '../service/firebase/firebase_api_user.dart';
import '../service/firebase/firebase_service.dart';
import '../service/shared/shared_preferences_service.dart';
import 'package:get_it/get_it.dart';

import '../service/api/dio_client.dart';
import '../data/datasources/course_remote_data_source.dart';
import '../data/datasources/enrollment_remote_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/enrollment_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../features/courses/viewmodel/courses_viewmodel.dart';
import '../features/courses/viewmodel/detail_course_viewmodel.dart';
import '../features/enrollments/viewmodel/enrollments_viewmodel.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register DioClient singleton
  locator.registerLazySingleton<DioClient>(() => DioClient(locator<SharedPreferences>()));

  // MVVM DataSources
  locator.registerLazySingleton<CourseRemoteDataSource>(
      () => CourseRemoteDataSourceImpl(locator<DioClient>()));
  locator.registerLazySingleton<EnrollmentRemoteDataSource>(
      () => EnrollmentRemoteDataSourceImpl(locator<DioClient>()));
  locator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(locator<DioClient>()));

  // MVVM Repositories
  locator.registerLazySingleton<CourseRepository>(
      () => CourseRepositoryImpl(locator<CourseRemoteDataSource>()));
  locator.registerLazySingleton<EnrollmentRepository>(
      () => EnrollmentRepositoryImpl(locator<EnrollmentRemoteDataSource>()));
  locator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(locator<AuthRemoteDataSource>()));

  // MVVM ViewModels (Factories provide fresh instance per screen lifecycle)
  locator.registerFactory<CoursesViewModel>(
      () => CoursesViewModel(locator<CourseRepository>()));
  locator.registerFactory<DetailCourseViewModel>(
      () => DetailCourseViewModel(locator<CourseRepository>(), locator<EnrollmentRepository>()));
  locator.registerFactory<EnrollmentsViewModel>(
      () => EnrollmentsViewModel(locator<EnrollmentRepository>()));
  locator.registerFactory<AuthViewModel>(
      () => AuthViewModel(locator<AuthRepository>()));

  // Register Firebase instances
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  locator
      .registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Register other services
  locator.registerLazySingleton(() => FirebaseApiRegistration());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => FirebaseApiNotifications());
  locator.registerLazySingleton(() => FirebaseApiQuiz());
  locator.registerLazySingleton(() => FirebaseApiCourses());
  locator.registerLazySingleton(() => FirebaseService());
  locator.registerLazySingleton(() => AuthServiceGoogle());
  locator.registerLazySingleton(() => FirebaseApiLecture());
  locator.registerLazySingleton(() => FirebaseApiCategories());
  locator.registerLazySingleton(() => SharedPreferencesService());
  locator.registerLazySingleton(() => FirebaseApiSection());
  locator.registerLazySingleton(() => LocalNotificationService());

  await locator.allReady();
}
