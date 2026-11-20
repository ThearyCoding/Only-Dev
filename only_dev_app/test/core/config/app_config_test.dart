import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/core/config/app_config.dart';
import 'package:only_dev_app/firebase_options.dart';

void main() {
  group('AppConfig Environment Tests', () {
    test('AppEnvironment.fromString parses environment strings correctly', () {
      expect(AppEnvironment.fromString('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromString('development'), AppEnvironment.dev);
      expect(AppEnvironment.fromString('uat'), AppEnvironment.uat);
      expect(AppEnvironment.fromString('staging'), AppEnvironment.uat);
      expect(AppEnvironment.fromString('prod'), AppEnvironment.prod);
      expect(AppEnvironment.fromString('production'), AppEnvironment.prod);
      expect(AppEnvironment.fromString(null), AppEnvironment.dev);
      expect(AppEnvironment.fromString('unknown'), AppEnvironment.dev);
    });

    test('AppConfig.dev properties are correct', () {
      final config = AppConfig.dev;
      expect(config.environment, AppEnvironment.dev);
      expect(config.isDev, isTrue);
      expect(config.isUat, isFalse);
      expect(config.isProd, isFalse);
      expect(config.appName, 'Only Dev (Dev)');
      expect(config.enableLogging, isTrue);
      expect(config.apiBaseUrl, isNotEmpty);
    });

    test('AppConfig.uat properties are correct', () {
      final config = AppConfig.uat;
      expect(config.environment, AppEnvironment.uat);
      expect(config.isDev, isFalse);
      expect(config.isUat, isTrue);
      expect(config.isProd, isFalse);
      expect(config.appName, 'Only Dev (UAT)');
      expect(config.enableLogging, isTrue);
      expect(config.apiBaseUrl, contains('uat'));
    });

    test('AppConfig.prod properties are correct', () {
      final config = AppConfig.prod;
      expect(config.environment, AppEnvironment.prod);
      expect(config.isDev, isFalse);
      expect(config.isUat, isFalse);
      expect(config.isProd, isTrue);
      expect(config.appName, 'Only Dev');
      expect(config.enableLogging, isFalse);
      expect(config.apiBaseUrl, 'https://api.onlydev.com/api/v1');
    });

    test('AppConfig.initialize overrides singleton instance', () {
      AppConfig.initialize(AppConfig.uat);
      expect(AppConfig.instance.environment, AppEnvironment.uat);
      expect(AppConfig.instance.isUat, isTrue);

      AppConfig.initialize(AppConfig.dev);
      expect(AppConfig.instance.environment, AppEnvironment.dev);
      expect(AppConfig.instance.isDev, isTrue);
    });
  });

  group('Firebase Options Multi-Environment Tests', () {
    test('DefaultFirebaseOptions.forEnvironment returns valid project configs', () {
      // Dev
      final devOptions = DefaultFirebaseOptions.forEnvironment(AppEnvironment.dev);
      expect(devOptions.projectId, 'only-dev-project');
      expect(devOptions.appId, isNotEmpty);

      // UAT
      final uatOptions = DefaultFirebaseOptions.forEnvironment(AppEnvironment.uat);
      expect(uatOptions.projectId, 'only-dev-project');
      expect(uatOptions.appId, isNotEmpty);

      // Prod
      final prodOptions = DefaultFirebaseOptions.forEnvironment(AppEnvironment.prod);
      expect(prodOptions.projectId, 'only-dev-project');
      expect(prodOptions.appId, isNotEmpty);
    });

    test('DefaultFirebaseOptions.currentPlatform reflects active AppConfig', () {
      AppConfig.initialize(AppConfig.uat);
      expect(DefaultFirebaseOptions.currentPlatform.projectId, 'only-dev-project');

      AppConfig.initialize(AppConfig.prod);
      expect(DefaultFirebaseOptions.currentPlatform.projectId, 'only-dev-project');

      AppConfig.initialize(AppConfig.dev);
      expect(DefaultFirebaseOptions.currentPlatform.projectId, 'only-dev-project');
    });
  });
}
