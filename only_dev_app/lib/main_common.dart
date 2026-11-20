import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'di/dependency_injection.dart';
import 'messaging/firebase_messaging_service.dart';
import 'my_app.dart';
import 'utils/easy_loading_configure_utils.dart';

/// Shared application bootstrap for all environments
Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(config);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupLocator();
  await FirebaseMessagingService.initialize();
  configEasyLoading();

  runApp(const ProviderScope(child: MyApp()));
}
