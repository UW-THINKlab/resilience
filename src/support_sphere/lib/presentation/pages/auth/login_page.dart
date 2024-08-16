import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/routes.dart';
import 'package:support_sphere/presentation/components/icon_logo.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/logic/cubit/login_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:support_sphere/presentation/components/auth/login_form.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(context.read<AuthenticationRepository>()),
      child: BlocBuilder<LoginCubit, LoginState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return LoadingOverlay(
              isLoading: false,
              child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                body: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20.0),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height / 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.home);
                        },
                        child: const IconLogo(),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: Text(
                          LoginStrings.loginIntoExisting,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      const LoginForm(),
                      const SizedBox(height: 10.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(LoginStrings.dontHaveAnAccount),
                            const SizedBox(width: 5.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.signup);
                              },
                              child: Text(
                                LoginStrings.signUp,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ]),
                    ]),
              ));
        },
      ),
    );
  }
}
