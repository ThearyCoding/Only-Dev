
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/provider/auth_provider.dart';
import 'common/provider/internet_connection_provider.dart';
import 'courses/provider/admin_provider.dart';
import 'courses/provider/course_list_provider.dart';
import 'courses/provider/banners_provider.dart';
import 'courses/provider/categories_provider.dart';
import 'courses/provider/course_provider.dart';
import 'courses/provider/lecture_provider.dart';
import 'enrollments/provider/enrollment_provider.dart';
import 'enrollments/provider/registration_provider.dart';
import 'notifications/provider/notification_provider.dart';
import 'profile/provider/user_provider.dart';
import 'quizzes/provider/quiz_provider.dart';
import 'search/provider/search_engine_provider.dart';
import 'settings/provider/language_provider.dart';
import 'settings/provider/theme_provider.dart';
import '../di/dependency_injection.dart';
import 'home/viewmodel/home_viewmodel.dart';
import '../my_app.dart';

class ProviderSetup extends StatefulWidget {
  const ProviderSetup({super.key});

  @override
  State<ProviderSetup> createState() => _ProviderSetupState();
}

class _ProviderSetupState extends State<ProviderSetup>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => InternetConnectionProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthenticationProvider(),
          
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, UserProvider>(
          create: (context) => UserProvider(
            Provider.of<AuthenticationProvider>(context, listen: false),
          ),
          update: (context, authProvider, userProvider) =>
              userProvider!..authProvider = authProvider,
        ),
        ChangeNotifierProvider(create: (context) => LectureProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => CategoriesProvider()),
        ChangeNotifierProvider(create: (context) => RegistrationProvider()),
        ChangeNotifierProvider(create: (context) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (context) => CustomizeThemeProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) => CourseListProvider(tickerProvider: this),
        ),
        ChangeNotifierProvider(create: (context) => SearchEngineProvider()),
        ChangeNotifierProvider(
          create: (context) => BannersProvider(),
        ),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => QuizProvider()),
        ChangeNotifierProvider(create: (context) => locator<HomeViewModel>()),
      ],
      child: const MyApp(),
    );
  }
}
