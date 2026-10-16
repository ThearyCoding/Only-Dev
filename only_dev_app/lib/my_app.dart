import 'package:flutter/material.dart';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/global_navigation.dart';
import 'generated/l10n.dart';
import 'messaging/firebase_messaging_service.dart';
import 'messaging/local_notification_service.dart';
import 'package:only_dev_app/features/common/provider/internet_connection_provider.dart';
import 'package:only_dev_app/features/settings/provider/language_provider.dart';
import 'package:only_dev_app/features/settings/provider/theme_provider.dart';
import 'routes/app_routes.dart';
import 'theme/custom_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRoutes.getRouter();
    FirebaseMessagingService.configureMessageHandlers();
    LocalNotificationService.initialize(_router);

    Provider.of<InternetConnectionProvider>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<CustomizeThemeProvider>(context, listen: false)
          .loadTheme(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
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
                    AppLocalizations.delegate,
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
