import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/auth_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/auth/view/login_with_social_media_or_sign_up_with_email.dart';
import 'package:only_dev_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:only_dev_app/generated/l10n.dart';

class MockAuthRepo implements AuthRepository {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return {
      'access_token': 'fake_token',
      'refresh_token': 'fake_refresh',
    };
  }

  @override
  Future<UserModel> getMe() async {
    return UserModel(
      uid: 'user-1',
      firstName: 'Student',
      lastName: 'Dev',
      fullName: 'Student Dev',
      email: 'student@onlydev.com',
      photoURL: '',
      gender: 1,
      dob: '',
      bgColor: '',
      backgroundColor: '',
      role: 'STUDENT',
    );
  }

  @override
  Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    return {'access_token': 'token'};
  }

  @override
  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String idToken,
    required String email,
    required String fullName,
    String? avatarUrl,
  }) async => {'access_token': 'token'};
}

void main() {
  setUp(() {
    if (locator.isRegistered<AuthViewModel>()) {
      locator.unregister<AuthViewModel>();
    }
    locator.registerFactory<AuthViewModel>(
      () => AuthViewModel(MockAuthRepo()),
    );
  });

  tearDown(() {
    if (locator.isRegistered<AuthViewModel>()) {
      locator.unregister<AuthViewModel>();
    }
  });

  testWidgets('Auth screen renders clean login view, switches to register, and demo autofill works', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LoginwithSocialMediaOrSignUpWithEmail(),
        ),
      ),
    );

    await tester.pump();

    // Verify initial Login state
    expect(find.text('Only Dev'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // Test Demo Autofill
    final demoFillFinder = find.text('Fill Demo Account (student@onlydev.com)');
    expect(demoFillFinder, findsOneWidget);
    await tester.tap(demoFillFinder);
    await tester.pump();

    expect(find.text('student@onlydev.com'), findsOneWidget);

    // Switch to Sign Up tab
    final signUpTabFinder = find.widgetWithText(GestureDetector, 'Sign Up');
    await tester.tap(signUpTabFinder);
    await tester.pump();

    // Verify Register View is displayed instantly
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });
}
