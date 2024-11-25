import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/constants.dart';
import 'di/dependency_injection.dart';
import 'messaging/firebase_messaging_service.dart';
import 'providers/provider_setup.dart';
import 'utils/easy_loading_configure_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Stripe.publishableKey = publishablekey;
  await FirebaseMessagingService.initialize();
  setupLocator();
  configEasyLoading();
  runApp(const ProviderSetup());
}
