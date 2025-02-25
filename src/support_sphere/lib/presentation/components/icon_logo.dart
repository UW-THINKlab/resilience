import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class IconLogo extends StatelessWidget {
const IconLogo({ super.key });

  @override
  Widget build(BuildContext context){
    return Container(
        // height: MediaQuery.of(context).size.height,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: FaIcon(
                  FontAwesomeIcons.peopleRoof,
                  size: 150.0,
                  color: Color.fromARGB(255, 15, 64, 86),
                ),
              ),
            ),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'Ubuntu-Regular',
              ),
            )
          ],
        ),
      );
  }
}
