import 'package:e_leaningapp/providers/auth_provider.dart';
import 'package:e_leaningapp/screens/auth-screen/login_with_social_media_or_sign_up_with_email.dart';
import 'package:e_leaningapp/utils/generate_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
          
          // Check if the user is authenticated
          if (currentUser != null) {
            // Access isLoggedIn from LocalStorageSharedPreferences controller
            bool isLoggedIn = authProvider.isLoggedIn;

            if (isLoggedIn) {
              return const MainPage();
            } else {
              // User not authenticated, navigate to LoginPage
              return FutureBuilder<bool>(
                future: UserService().isInformationComplete(currentUser).first,
                builder: (context, infoSnapshot) {
                  GenerateColor.onUserLogin();
                  if (infoSnapshot.connectionState == ConnectionState.waiting) {
                    // Information completeness is being verified, show loading indicator
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else {
                    if (infoSnapshot.data == true) {
                      authProvider.saveUserLoginStatus(true);
                      // User authenticated and information is complete, navigate to HomePage
                      return const MainPage();
                    } else {
                      // Schedule navigation after the current frame is rendered
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.push(
                          RoutesPath.completeInfo,
                          extra: currentUser,
                        );
                      });

                      return const SizedBox(); // Returning an empty widget as the navigation will take the user away from this screen
                    }
                  }
                },
              );
            }
          } else {
            // User not authenticated, navigate to LoginPage
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
