
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../export/provider_export.dart';
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
        ChangeNotifierProvider(create: (context) => CustomizeThemeProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) => AllCoursesProvider(tickerProvider: this),
        ),
        ChangeNotifierProvider(create: (context) => SearchEngineProvider()),
        ChangeNotifierProvider(
          create: (context) => BannersProvider(),
        ),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => QuizProvider())
      ],
      child: const MyApp(),
    );
  }
}
