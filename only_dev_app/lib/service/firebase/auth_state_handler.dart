import 'package:only_dev_app/features/auth/provider/auth_provider.dart';
import 'package:only_dev_app/features/auth/view/login_with_social_media_or_sign_up_with_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import 'package:only_dev_app/data/repositories/user_repository.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/home/view/main_screen.dart';
import 'package:only_dev_app/service/api/dio_client.dart';

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  Future<bool> _checkInfoComplete(User currentUser) async {
    try {
      final profile = await locator<UserRepository>().getMyProfile();
      return profile.fullName.trim().isNotEmpty && profile.fullName != 'Unknown';
    } catch (_) {
      return (currentUser.displayName?.isNotEmpty ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.connectionState == ConnectionState.active) {
          User? currentUser = snapshot.data;

          if (currentUser != null) {
            bool isLoggedIn = authProvider.isLoggedIn;

            if (isLoggedIn) {
              return const MainPage();
            } else {
              return FutureBuilder<bool>(
                future: _checkInfoComplete(currentUser),
                builder: (context, infoSnapshot) {
                  if (infoSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else {
                    if (infoSnapshot.data == true) {
                      authProvider.saveUserLoginStatus(true);
                      return const MainPage();
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.push(
                          RoutesPath.completeInfo,
                          extra: currentUser,
                        );
                      });

                      return const SizedBox.shrink();
                    }
                  }
                },
              );
            }
          } else {
            final token = locator<DioClient>().authInterceptor.token;
            if (authProvider.isLoggedIn && token != null && token.isNotEmpty) {
              return const MainPage();
            }
            return const LoginwithSocialMediaOrSignUpWithEmail();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        final token = locator<DioClient>().authInterceptor.token;
        if (authProvider.isLoggedIn && token != null && token.isNotEmpty) {
          return const MainPage();
        }
        return const LoginwithSocialMediaOrSignUpWithEmail();
      },
    );
  }
}
