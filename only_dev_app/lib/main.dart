import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'di/dependency_injection.dart';
import 'messaging/firebase_messaging_service.dart';
import 'features/provider_setup.dart';
import 'utils/easy_loading_configure_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await setupLocator();
  await FirebaseMessagingService.initialize();
  configEasyLoading();
  runApp(const ProviderSetup());
}
