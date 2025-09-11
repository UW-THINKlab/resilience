import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:support_sphere/presentation/pages/main_app/app_page.dart';
import 'package:support_sphere/presentation/router/flows/onboarding_flow.dart';

/// Selects the appropriate page to display based on the user's authentication status
class AuthSelect extends StatelessWidget {
  const AuthSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthenticationBloc(
          authenticationRepository: context.read<AuthenticationRepository>()),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (_, state) {
          AuthenticationStatus authStatus = state.status;
          switch (authStatus) {
            case AuthenticationStatus.authenticated:
              /// If the user is authenticated, display the main app page
              return const AppPage();
              // return const AppPage();
            case AuthenticationStatus.unauthenticated:
              /// If the user is not authenticated, display the onboarding flow
              return const OnboardingFlow();
            }
        },
      ),
    );
  }
}
