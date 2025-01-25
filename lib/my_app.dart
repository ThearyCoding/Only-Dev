import 'package:flutter/material.dart';

import 'core/global_navigation.dart';
import 'export/export.dart';
import 'export/provider_export.dart';

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
    AwesomeNotificationService.initialize(_router);

    fToast = FToast();
    fToast!.init(context);
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
