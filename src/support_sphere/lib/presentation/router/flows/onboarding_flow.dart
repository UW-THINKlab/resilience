import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/presentation/pages/auth/login_page.dart';
import 'package:support_sphere/presentation/pages/auth/signup_page.dart';
import 'package:support_sphere/presentation/pages/landing_page.dart';

enum OnboardingSteps {
  landing,
  login,
  signup,
}

List<Page> onGeneratePages(OnboardingSteps step, List<Page<dynamic>> pages) {
    switch(step) {
      case OnboardingSteps.landing:
        return [Login.page(), Landing.page()];
      case OnboardingSteps.login:
        return [Landing.page(), Signup.page(), Login.page()];
      case OnboardingSteps.signup:
        return [Login.page(), Signup.page()];
      default:
        return [Landing.page()];
    }
}

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({ super.key });

  static Route route() => MaterialPageRoute(builder: (_) => const OnboardingFlow());

  @override
  Widget build(BuildContext context){
    return const FlowBuilder<OnboardingSteps>(onGeneratePages: onGeneratePages, state: OnboardingSteps.landing);
  }
}
