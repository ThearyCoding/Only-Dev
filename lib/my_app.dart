import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import '../../export/curriculum_export.dart';
import '../../generated/l10n.dart';
import '../../messaging/awesome_notification_service.dart';
import '../../messaging/firebase_messaging_service.dart';
import '../../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/global_navigation.dart';
import 'providers/internet_connection_provider.dart';
import 'providers/language_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late GoRouter _router;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    _router = AppRoutes.getRouter();
    FirebaseMessagingService.configureMessageHandlers();
    AwesomeNotificationService.initialize(_router);

    fToast = FToast();
    fToast.init(context);
    Provider.of<InternetConnectionProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<CustomizeThemeProvider>(context, listen: false)
          .loadTheme(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final CustomizeThemeProvider themeProvider =
            Provider.of<CustomizeThemeProvider>(context);
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return ThemeProvider(
              initTheme: themeProvider.currentTheme == ThemeMode.dark
                  ? CustomThemes.darkTheme
                  : CustomThemes.lightTheme,
              builder: (context, myTheme) {
                return MaterialApp.router(
                  routerConfig: _router,
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  debugShowCheckedModeBanner: false,
                  theme: myTheme,
                  darkTheme: CustomThemes.darkTheme,
                  themeMode: themeProvider.currentTheme,
                  locale: languageProvider.locale,
                  supportedLocales: const [
                    Locale('en', ''),
                    Locale('km', ''),
                  ],
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  builder: EasyLoading.init(),
                );
              },
            );
          },
        );
      },
    );
  }
}
