import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/presentation/components/icon_logo.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/constants/color.dart';
import 'package:support_sphere/presentation/router/flows/onboarding_flow.dart';

class Landing extends StatelessWidget{
  const Landing({super.key});

  static MaterialPage page() => const MaterialPage(child: LandingView());

  @override
  Widget build(BuildContext context) {
    return const OnboardingFlow();
  }
}

class LandingView extends StatelessWidget {
const LandingView({ super.key });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: const IconLogo(),
      bottomNavigationBar: BottomAppBar(
        color: ColorConstants.transparent,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Login button
              Container(
                height: 45.0,
                width: 130.0,
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
                    LoginStrings.login,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => context
                  .flow<OnboardingSteps>()
                  .update((next) => OnboardingSteps.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
