import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/auth/provider/auth_provider.dart';
import 'package:only_dev_app/features/settings/provider/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'isLoggedIn': true, 'isdarkMode': true});
  });

  group('Theme, UserProvider & AuthenticationProvider Tests', () {
    test('CustomizeThemeProvider switches theme immediately without animation dependencies', () {
      final themeProvider = CustomizeThemeProvider();
      expect(themeProvider.currentTheme, equals(ThemeMode.dark));

      themeProvider.switchTheme();
      expect(themeProvider.currentTheme, equals(ThemeMode.light));

      themeProvider.switchTheme();
      expect(themeProvider.currentTheme, equals(ThemeMode.dark));
    });

    test('AuthenticationProvider notifyListeners does not throw after dispose', () {
      final authProvider = AuthenticationProvider();
      authProvider.dispose();
      expect(authProvider.isDisposed, isTrue);

      // Calling notifyListeners after dispose should be safely swallowed
      expect(() => authProvider.notifyListeners(), returnsNormally);
    });

    test('userNotifierProvider is not recreated when authNotifierProvider notifies', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Read both providers
      final initialUserProvider = container.read(userNotifierProvider);
      final authProvider = container.read(authNotifierProvider);

      expect(initialUserProvider.isDisposed, isFalse);

      // Trigger notification in authProvider (like during logout or login status change)
      await authProvider.saveUserLoginStatus(false);

      // Verify userNotifierProvider instance was NOT destroyed/recreated
      final currentUserProvider = container.read(userNotifierProvider);
      expect(identical(currentUserProvider, initialUserProvider), isTrue);
      expect(initialUserProvider.isDisposed, isFalse);
    });

    test('UserProvider notifyListeners does not throw when disposed', () {
      final container = ProviderContainer();
      final userProvider = container.read(userNotifierProvider);
      container.dispose();

      expect(userProvider.isDisposed, isTrue);
      // Calling notifyListeners after dispose should be safely swallowed without throwing FlutterError
      expect(() => userProvider.notifyListeners(), returnsNormally);
    });
  });
}
