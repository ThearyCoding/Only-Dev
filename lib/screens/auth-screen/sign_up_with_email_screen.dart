import 'package:e_leaningapp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../../export/export.dart';
import '../../widgets/buttons/custom_btn_loading_widget.dart';

class SignUpWithEmailScreen extends StatelessWidget {
  SignUpWithEmailScreen({super.key, required this.onSwitchToLogin});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController txtemail = TextEditingController();
  final TextEditingController txtpassword = TextEditingController();
  final TextEditingController txtconfirmPassword = TextEditingController();
  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider controller = Provider.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        onSwitchToLogin();
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
                  const SizedBox(height: 20),
                  Text(
                    "Create an account to access all features of our e-learning platform.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextFieldWidget02(
                    labelText: 'Email | ',
                    controller: txtemail,
                    hintText: 'Enter Email',
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
                  const SizedBox(height: 20),
                  CustomTextFieldWidget02(
                    labelText: 'Password | ',
                    controller: txtpassword,
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
                  const SizedBox(height: 20),
                  CustomTextFieldWidget02(
                    labelText: 'Confirm Password | ',
                    controller: txtconfirmPassword,
                    hintText: 'Confirm password',
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return 'Please confirm your password';
                      } else if (input != txtpassword.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    obscureText: true,
                    hoverBorderColor: Colors.green,
                    focusedBorderColor: Colors.green,
                    defaultBorderColor: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomBtnLoadingWidget(
                      btnText: "Login",
                      onTap: (startLoading, stopLoading, btnState) async {
                        if (_formKey.currentState!.validate()) {
                          startLoading();
                          if (_formKey.currentState!.validate()) {
                            await controller.signUp(
                                txtemail.text, txtpassword.text);
                          }
                          stopLoading();
                        }
                      },
                      backgroundColor: Colors.blue,
                      isInput: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onSwitchToLogin,
                    child: Text(
                      "Already have an account? Log in here",
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
  }
}
