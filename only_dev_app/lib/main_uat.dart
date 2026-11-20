import 'core/config/app_config.dart';
import 'main_common.dart';

/// Explicit UAT (User Acceptance Testing / Staging) entry point
Future<void> main() async {
  await mainCommon(AppConfig.uat);
}
