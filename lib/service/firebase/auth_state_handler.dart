import 'package:e_leaningapp/providers/auth_provider.dart';
import 'package:e_leaningapp/screens/auth-screen/login_with_social_media_or_sign_up_with_email.dart';
import 'package:e_leaningapp/utils/generate_color.dart';
import 'package:flutter/material.dart';
import '../../export/export.dart';

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

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
                future: UserService().isInformationComplete(currentUser).first,
                builder: (context, infoSnapshot) {
                  GenerateColor.onUserLogin();
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
            return const LoginwithSocialMediaOrSignUpWithEmail();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return const LoginwithSocialMediaOrSignUpWithEmail();
      },
    );
  }
}
