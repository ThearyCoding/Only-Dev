// File generated & configured for Multi-Environment support (dev, uat, prod)
// Firebase project: only-dev-project
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'core/config/app_config.dart';

/// Default [FirebaseOptions] for use with your Firebase apps across multi-environments (dev, uat, prod).
class DefaultFirebaseOptions {
  /// Resolves the FirebaseOptions for the currently active AppConfig environment and platform.
  static FirebaseOptions get currentPlatform {
    return forEnvironment(AppConfig.instance.environment);
  }

  /// Explicitly resolves FirebaseOptions for a given AppEnvironment.
  static FirebaseOptions forEnvironment(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.uat:
        return _resolvePlatform(uatWeb, uatAndroid, uatIos, uatMacos);
      case AppEnvironment.prod:
        return _resolvePlatform(prodWeb, prodAndroid, prodIos, prodMacos);
      case AppEnvironment.dev:
        return _resolvePlatform(devWeb, devAndroid, devIos, devMacos);
    }
  }

  static FirebaseOptions _resolvePlatform(
    FirebaseOptions web,
    FirebaseOptions android,
    FirebaseOptions ios,
    FirebaseOptions macos,
  ) {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ===========================================================================
  // 1. DEVELOPMENT FIREBASE OPTIONS (only-dev-project / com.onlydev.app.dev)
  // ===========================================================================
  static const FirebaseOptions devWeb = FirebaseOptions(
    apiKey: 'AIzaSyCM-wz416RsuoAaJws-RNSoJJmz3QLV_DY',
    appId: '1:644837978602:web:b8352d1547265078efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    authDomain: 'only-dev-project.firebaseapp.com',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions devAndroid = FirebaseOptions(
    apiKey: 'AIzaSyDXfbLs8v7Z_lLLQv95w9_ST0We-iaILcA',
    appId: '1:644837978602:android:11ea53d6dc0a62e5efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions devIos = FirebaseOptions(
    apiKey: 'AIzaSyDRYoOCpF3FltsdWuhL866f1E0Am4azdIg',
    appId: '1:644837978602:ios:c06abae348714568efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
    iosBundleId: 'com.onlydev.app.dev',
  );

  static const FirebaseOptions devMacos = FirebaseOptions(
    apiKey: 'AIzaSyDRYoOCpF3FltsdWuhL866f1E0Am4azdIg',
    appId: '1:644837978602:ios:c06abae348714568efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
    iosBundleId: 'com.onlydev.app.dev.RunnerTests',
  );

  // ===========================================================================
  // 2. UAT FIREBASE OPTIONS (onlydev-uat / com.onlydev.app.uat)
  // ===========================================================================
  static const FirebaseOptions uatWeb = FirebaseOptions(
    apiKey: 'AIzaSyCM-wz416RsuoAaJws-RNSoJJmz3QLV_DY',
    appId: '1:644837978602:web:b8352d1547265078efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    authDomain: 'only-dev-project.firebaseapp.com',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions uatAndroid = FirebaseOptions(
    apiKey: 'AIzaSyDXfbLs8v7Z_lLLQv95w9_ST0We-iaILcA',
    appId: '1:644837978602:android:11ea53d6dc0a62e5efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions uatIos = FirebaseOptions(
    apiKey: 'AIzaSyDRYoOCpF3FltsdWuhL866f1E0Am4azdIg',
    appId: '1:644837978602:ios:c06abae348714568efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
    iosBundleId: 'com.onlydev.app.uat',
  );

  static const FirebaseOptions uatMacos = FirebaseOptions(
    apiKey: 'AIzaSyDRYoOCpF3FltsdWuhL866f1E0Am4azdIg',
    appId: '1:644837978602:ios:c06abae348714568efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
    iosBundleId: 'com.onlydev.app.uat.RunnerTests',
  );

  // ===========================================================================
  // 3. PRODUCTION FIREBASE OPTIONS (only-dev-project / com.onlydev.app)
  // ===========================================================================
  static const FirebaseOptions prodWeb = FirebaseOptions(
    apiKey: 'AIzaSyCM-wz416RsuoAaJws-RNSoJJmz3QLV_DY',
    appId: '1:644837978602:web:b8352d1547265078efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    authDomain: 'only-dev-project.firebaseapp.com',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions prodAndroid = FirebaseOptions(
    apiKey: 'AIzaSyDXfbLs8v7Z_lLLQv95w9_ST0We-iaILcA',
    appId: '1:644837978602:android:11ea53d6dc0a62e5efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions prodIos = FirebaseOptions(
    apiKey: 'AIzaSyDRYoOCpF3FltsdWuhL866f1E0Am4azdIg',
    appId: '1:644837978602:ios:c06abae348714568efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
    iosBundleId: 'com.onlydev.app',
  );

  static const FirebaseOptions prodMacos = FirebaseOptions(
    apiKey: 'AIzaSyDRYoOCpF3FltsdWuhL866f1E0Am4azdIg',
    appId: '1:644837978602:ios:c06abae348714568efc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    storageBucket: 'only-dev-project.firebasestorage.app',
    iosBundleId: 'com.onlydev.app.RunnerTests',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCM-wz416RsuoAaJws-RNSoJJmz3QLV_DY',
    appId: '1:644837978602:web:0cff88f28ff5478defc293',
    messagingSenderId: '644837978602',
    projectId: 'only-dev-project',
    authDomain: 'only-dev-project.firebaseapp.com',
    storageBucket: 'only-dev-project.firebasestorage.app',
  );

  // Backward compatibility getters
  static FirebaseOptions get web => prodWeb;
  static FirebaseOptions get android => prodAndroid;
  static FirebaseOptions get ios => prodIos;
  static FirebaseOptions get macos => prodMacos;
}
