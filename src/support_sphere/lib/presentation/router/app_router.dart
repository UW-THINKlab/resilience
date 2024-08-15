import 'package:flutter/material.dart';
import 'package:support_sphere/presentation/pages/auth/login_page.dart';
import 'package:support_sphere/presentation/pages/auth/register_page.dart';
import 'package:support_sphere/presentation/pages/landing_page.dart';
import 'package:support_sphere/constants/routes.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const Landing());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const Login());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const Register());
    }
    return null;
  }
}
