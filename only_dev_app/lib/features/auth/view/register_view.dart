import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/core/viewmodel/base_view.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/buttons/custom_btn_loading_widget.dart';
import 'package:only_dev_app/widgets/textfield/custom_text_field_widget_02.dart';
import '../viewmodel/auth_viewmodel.dart';

class RegisterView extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToLogin;

  const RegisterView({super.key, this.onSwitchToLogin});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            if (widget.onSwitchToLogin != null) {
              widget.onSwitchToLogin!();
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
                      Text(
                        "Sign Up to Continue",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Create an account to access all features of Only Dev.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFieldWidget02(
                        labelText: 'Full Name | ',
                        controller: _fullNameController,
                        hintText: 'Enter your full name',
                        validator: (input) {
                          if (input == null || input.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        obscureText: false,
                        hoverBorderColor: Colors.green,
                        focusedBorderColor: Colors.green,
                        defaultBorderColor: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFieldWidget02(
                        labelText: 'Email | ',
                        controller: _emailController,
                        hintText: 'Enter Email',
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!input.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        obscureText: false,
                        hoverBorderColor: Colors.green,
                        focusedBorderColor: Colors.green,
                        defaultBorderColor: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFieldWidget02(
                        labelText: 'Password | ',
                        controller: _passwordController,
                        hintText: 'Enter Password',
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
                      const SizedBox(height: 16),
                      CustomTextFieldWidget02(
                        labelText: 'Confirm Password | ',
                        controller: _confirmPasswordController,
                        hintText: 'Confirm password',
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return 'Please confirm your password';
                          } else if (input != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        obscureText: true,
                        hoverBorderColor: Colors.green,
                        focusedBorderColor: Colors.green,
                        defaultBorderColor: Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      CustomBtnLoadingWidget(
                        btnText: "Sign Up",
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (_formKey.currentState!.validate()) {
                            startLoading();
                            final success = await model.register(
                              email: _emailController.text,
                              password: _passwordController.text,
                              fullName: _fullNameController.text,
                            );
                            stopLoading();
                            if (success && context.mounted) {
                              if (model.currentUser != null) {
                                ref
                                    .read(userNotifierProvider)
                                    .setUserData(model.currentUser!);
                              }
                              await ref
                                  .read(authNotifierProvider)
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
                      const SizedBox(height: 12),
                      if (widget.onSwitchToLogin != null)
                        TextButton(
                          onPressed: widget.onSwitchToLogin,
                          child: Text(
                            "Already have an account? Login here",
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

