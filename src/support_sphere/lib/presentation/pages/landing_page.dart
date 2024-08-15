import 'package:flutter/material.dart';
import 'package:support_sphere/presentation/components/icon_logo.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/constants/color.dart';
import 'package:support_sphere/constants/routes.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    print("Login clicked");
                    Navigator.of(context).pushNamed(AppRoutes.login);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
