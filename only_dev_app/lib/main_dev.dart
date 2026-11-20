import 'core/config/app_config.dart';
import 'main_common.dart';

/// Explicit Development entry point
Future<void> main() async {
  await mainCommon(AppConfig.dev);
}
