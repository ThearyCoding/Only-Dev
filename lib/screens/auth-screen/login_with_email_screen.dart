import 'package:e_leaningapp/providers/auth_provider.dart';
import 'package:e_leaningapp/widgets/buttons/custom_btn_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../export/export.dart';

class LoginWithEmailScreen extends StatelessWidget {
  final VoidCallback onSwitchToSignUp;
  LoginWithEmailScreen({super.key, required this.onSwitchToSignUp});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtemail = TextEditingController();
  final TextEditingController _txtpassowrd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onSwitchToSignUp();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                                  Colors.black54,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                CustomTextFieldWidget02(
                  controller: _txtemail,
                  labelText: 'Email | ',
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  onSaved: (input) => _txtemail.text = input!,
                  obscureText: false,
                  hoverBorderColor: Colors.green,
                  focusedBorderColor: Colors.green,
                  defaultBorderColor: Colors.grey,
                ),
                const SizedBox(height: 10),
                CustomTextFieldWidget02(
                  controller: _txtpassowrd,
                  labelText: 'Password | ',
                  validator: (input) {
                    if (input == null || input.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (input) => _txtpassowrd.text = input!,
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
                      await authProvider.login(
                          _txtemail.text, _txtpassowrd.text);
                          stopLoading();
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onSwitchToSignUp,
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
    );
  }
}
