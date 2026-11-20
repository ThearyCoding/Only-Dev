import 'core/config/app_config.dart';
import 'main_common.dart';

/// Default entry point: dynamically resolves environment from --dart-define
/// or falls back to AppEnvironment.dev.
Future<void> main() async {
  await mainCommon(AppConfig.fromEnvironment());
}
