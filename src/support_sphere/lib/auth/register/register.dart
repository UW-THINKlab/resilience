import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/components/text_form_builder.dart';
import 'package:support_sphere/components/password_form_builder.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          body: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Text(
                'Welcome to Support Sphere\nCreate a new account and prepare with your community',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 30.0),
              buildForm(context),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  buildForm(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormBuilder(
            enabled: true,
            prefix: Ionicons.person_outline,
            hintText: "Username",
            textInputAction: TextInputAction.next,
            onSaved: (String val) {
              print(val);
              // Set the username
            },
          ),
          const SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: true,
            prefix: Ionicons.mail_outline,
            hintText: "Email",
            textInputAction: TextInputAction.next,
            onSaved: (String val) {
              print(val);
              // Set the email
            },
          ),
          const SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: true,
            prefix: Ionicons.qr_code_outline,
            hintText: "Sign Up Code",
            textInputAction: TextInputAction.next,
            onSaved: (String val) {
              print(val);
              // Set the sign up code
            },
          ),
          const SizedBox(height: 20.0),
          PasswordFormBuilder(
            enabled: true,
            prefix: Ionicons.lock_closed_outline,
            suffix: Ionicons.eye_outline,
            hintText: "Password",
            textInputAction: TextInputAction.done,
            obscureText: false,
            onSaved: (String val) {
              print(val);
              // Set the password
            },
          ),
          const SizedBox(height: 20.0),
          PasswordFormBuilder(
            enabled: true,
            prefix: Ionicons.lock_open_outline,
            suffix: Ionicons.eye_outline,
            hintText: "Confirm Password",
            textInputAction: TextInputAction.done,
            obscureText: false,
            onSaved: (String val) {
              print(val);
              // Set the confirm password
            },
          ),
          const SizedBox(height: 25.0),
          Container(
            height: 45.0,
            width: 180.0,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              // highlightElevation: 4.0,
              child: const Text(
                "SIGN UP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => {print("Registration submitted")},
            ),
          ),
        ],
      ),
    );
  }
}
