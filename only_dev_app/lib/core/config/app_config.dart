import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Available application deployment environments
enum AppEnvironment {
  dev,
  uat,
  prod;

  static AppEnvironment fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'uat':
      case 'staging':
        return AppEnvironment.uat;
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }
}

/// Central application environment configuration
class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;

  static AppConfig? _instance;

  AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    this.enableLogging = true,
  });

  /// Access the active environment singleton
  static AppConfig get instance {
    _instance ??= AppConfig.fromEnvironment();
    return _instance!;
  }

  /// Initialize the configuration before running the app
  static void initialize(AppConfig config) {
    _instance = config;
  }

  bool get isDev => environment == AppEnvironment.dev;
  bool get isUat => environment == AppEnvironment.uat;
  bool get isProd => environment == AppEnvironment.prod;

  /// Dynamic resolution of the local development backend host:
  /// - Android Emulator requires 10.0.2.2 to bridge to the host machine.
  /// - iOS Simulator, macOS, Desktop, and Web connect directly to localhost.
  static String get defaultDevBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:4000/api/v1';
    }
    return 'http://localhost:4000/api/v1';
  }

  /// Development configuration preset
  static AppConfig get dev {
    const customUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return AppConfig(
      environment: AppEnvironment.dev,
      appName: 'Only Dev (Dev)',
      apiBaseUrl: customUrl.isNotEmpty ? customUrl : defaultDevBaseUrl,
      enableLogging: true,
    );
  }

  /// UAT (User Acceptance Testing / Staging) configuration preset
  static AppConfig get uat {
    const customUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return AppConfig(
      environment: AppEnvironment.uat,
      appName: 'Only Dev (UAT)',
      apiBaseUrl: customUrl.isNotEmpty ? customUrl : 'https://uat-api.onlydev.com/api/v1',
      enableLogging: true,
    );
  }

  /// Production configuration preset
  static AppConfig get prod {
    const customUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return AppConfig(
      environment: AppEnvironment.prod,
      appName: 'Only Dev',
      apiBaseUrl: customUrl.isNotEmpty ? customUrl : 'https://api.onlydev.com/api/v1',
      enableLogging: false,
    );
  }

  /// Resolves configuration from compile-time flags (--dart-define=ENV=dev|uat|prod)
  static AppConfig fromEnvironment() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    final env = AppEnvironment.fromString(envString);
    switch (env) {
      case AppEnvironment.uat:
        return uat;
      case AppEnvironment.prod:
        return prod;
      case AppEnvironment.dev:
        return dev;
    }
  }
}
