import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/features/auth/provider/auth_provider.dart';
import 'package:only_dev_app/features/profile/provider/user_provider.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/buttons/custom_btn_loading_widget.dart';
import 'package:only_dev_app/widgets/textfield/custom_text_field_widget_02.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  final VoidCallback? onSwitchToSignUp;

  const LoginView({super.key, this.onSwitchToSignUp});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseView<AuthViewModel>(
      builder: (context, model, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (widget.onSwitchToSignUp != null) {
              widget.onSwitchToSignUp!();
            }
          },
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Let's Login with Your Email",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color ??
                                  Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "Welcome back! Please enter your email and password to login.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color ??
                                    Colors.black54,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      CustomTextFieldWidget02(
                        controller: _emailController,
                        labelText: 'Email | ',
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                        obscureText: false,
                        hoverBorderColor: Colors.green,
                        focusedBorderColor: Colors.green,
                        defaultBorderColor: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      CustomTextFieldWidget02(
                        controller: _passwordController,
                        labelText: 'Password | ',
                        validator: (input) {
                          if (input == null || input.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        obscureText: true,
                        hoverBorderColor: Colors.green,
                        focusedBorderColor: Colors.green,
                        defaultBorderColor: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      CustomBtnLoadingWidget(
                        btnText: "Login",
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (_formKey.currentState!.validate()) {
                            startLoading();
                            final success = await model.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                            stopLoading();
                            if (success && context.mounted) {
                              if (model.currentUser != null) {
                                Provider.of<UserProvider>(context, listen: false)
                                    .setUserData(model.currentUser!);
                              }
                              await Provider.of<AuthenticationProvider>(context, listen: false)
                                  .saveUserLoginStatus(true);
                              if (context.mounted) {
                                context.go(RoutesPath.home);
                              }
                            }
                          }
                        },
                        backgroundColor: isDark ? Colors.blue : Colors.blueGrey,
                        isInput: true,
                      ),
                      const SizedBox(height: 10),
                      if (widget.onSwitchToSignUp != null)
                        TextButton(
                          onPressed: widget.onSwitchToSignUp,
                          child: Text(
                            "Don't have an account? Sign up here",
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

