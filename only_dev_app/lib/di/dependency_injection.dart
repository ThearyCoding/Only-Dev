
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../messaging/local_notification_service.dart';
import '../service/firebase/auth_service_google.dart';
import '../service/shared/shared_preferences_service.dart';
import 'package:get_it/get_it.dart';

import '../service/api/dio_client.dart';
import '../data/datasources/course_remote_data_source.dart';
import '../data/datasources/enrollment_remote_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/storage_remote_data_source.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../data/datasources/quiz_remote_data_source.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/enrollment_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/storage_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/post_repository.dart';
import '../features/courses/viewmodel/courses_viewmodel.dart';
import '../features/courses/viewmodel/course_detail_viewmodel.dart';
import '../features/enrollments/viewmodel/enrollments_viewmodel.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../features/home/datasource/home_remote_data_source.dart';
import '../features/home/repository/home_repository.dart';
import '../features/home/viewmodel/home_viewmodel.dart';

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
  locator.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(locator<DioClient>()));
  locator.registerLazySingleton<StorageRemoteDataSource>(
      () => StorageRemoteDataSourceImpl(locator<DioClient>()));
  locator.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(locator<DioClient>()));
  locator.registerLazySingleton<QuizRemoteDataSource>(
      () => QuizRemoteDataSourceImpl(locator<DioClient>()));

  // MVVM Repositories
  locator.registerLazySingleton<CourseRepository>(
      () => CourseRepositoryImpl(locator<CourseRemoteDataSource>()));
  locator.registerLazySingleton<EnrollmentRepository>(
      () => EnrollmentRepositoryImpl(locator<EnrollmentRemoteDataSource>()));
  locator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(locator<AuthRemoteDataSource>()));
  locator.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(locator<HomeRemoteDataSource>()));
  locator.registerLazySingleton<StorageRepository>(
      () => StorageRepositoryImpl(locator<StorageRemoteDataSource>()));
  locator.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(locator<UserRemoteDataSource>()));
  locator.registerLazySingleton<QuizRepository>(
      () => QuizRepositoryImpl(locator<QuizRemoteDataSource>()));
  locator.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl());

  // MVVM ViewModels (Factories provide fresh instance per screen lifecycle)
  locator.registerFactory<CoursesViewModel>(
      () => CoursesViewModel(locator<CourseRepository>()));
  locator.registerFactory<CourseDetailViewModel>(
      () => CourseDetailViewModel(locator<CourseRepository>(), locator<EnrollmentRepository>()));
  locator.registerFactory<EnrollmentsViewModel>(
      () => EnrollmentsViewModel(locator<EnrollmentRepository>()));
  locator.registerFactory<AuthViewModel>(
      () => AuthViewModel(locator<AuthRepository>()));
  locator.registerFactory<HomeViewModel>(
      () => HomeViewModel(locator<HomeRepository>()));

  // Register Firebase instances
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register other services
  locator.registerLazySingleton(() => AuthServiceGoogle());
  locator.registerLazySingleton(() => SharedPreferencesService());
  locator.registerLazySingleton(() => LocalNotificationService());

  await locator.allReady();
}
