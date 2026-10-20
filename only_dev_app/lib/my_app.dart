import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/global_navigation.dart';
import 'core/providers/app_providers.dart';
import 'generated/l10n.dart';
import 'messaging/firebase_messaging_service.dart';
import 'messaging/local_notification_service.dart';
import 'routes/app_routes.dart';
import 'theme/custom_theme.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  final GoRouter _router = AppRoutes.router;

  @override
  void initState() {
    super.initState();
    FirebaseMessagingService.configureMessageHandlers();
    LocalNotificationService.initialize(_router);

    // Initialize internet connection watcher & restore auth session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(internetConnectionNotifierProvider);
      ref.read(authNotifierProvider).loadUserLoginStatus();
      ref.read(userProfileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeNotifierProvider);
    final languageProvider = ref.watch(languageNotifierProvider);

    return MaterialApp.router(
      title: 'Only Dev',
      routerConfig: _router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: CustomThemes.lightTheme,
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
  }
}
