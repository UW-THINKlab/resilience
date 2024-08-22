import 'package:flow_builder/flow_builder.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/logic/cubit/signup_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:support_sphere/presentation/components/auth/signup_form.dart';
import 'package:support_sphere/presentation/router/flows/onboarding_flow.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  static MaterialPage page() => const MaterialPage(child: Signup());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(context.read<AuthenticationRepository>()),
      child: BlocBuilder<SignupCubit, SignupState>(
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
                      Text(
                        AppStrings.signUpWelcome,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      const SignupForm(),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            LoginStrings.alreadyHaveAnAccount,
                          ),
                          const SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () => context
                                .flow<OnboardingSteps>()
                                .update((previous) => OnboardingSteps.login),
                            child: Text(
                              LoginStrings.login,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ));
        },
      ),
    );
  }
}
