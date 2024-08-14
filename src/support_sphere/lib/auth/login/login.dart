import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/components/icon_logo.dart';
import 'package:support_sphere/components/text_form_builder.dart';
import 'package:support_sphere/components/password_form_builder.dart';
import 'package:support_sphere/auth/register/register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    // TODO: LoginViewModel viewModel = Provider.of<LoginViewModel>(context);
    // Need to create a view model and controller for login
    return LoadingOverlay(
        isLoading: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          // TODO: key: viewModel.scaffoldKey,
          body: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const IconLogo(),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    'Log into an existing account',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                buildForm(context),
                const SizedBox(height: 10.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Don\'t have an account?'),
                  const SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Register(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ]),
              ]),
        ));
  }

  buildForm(BuildContext context) {
    return Form(
        child: Column(
      children: [
        const TextFormBuilder(
          enabled: true,
          prefix: Ionicons.mail_outline,
          hintText: "Email",
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10.0),
        const PasswordFormBuilder(
          enabled: true,
          prefix: Ionicons.lock_closed_outline,
          suffix: Ionicons.eye_outline,
          hintText: "Password",
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      print("Forgot password clicked");
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
            ],
          ),
        ),
        const SizedBox(height: 10.0),
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
              "LOGIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => {print("Login submitted")},
          ),
        ),
      ],
    ));
  }

}
