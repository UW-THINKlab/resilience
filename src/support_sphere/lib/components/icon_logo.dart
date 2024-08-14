import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';

class IconLogo extends StatelessWidget {
const IconLogo({ Key? key }) : super(key: key);

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
                child: Icon(
                  Ionicons.earth_sharp,
                  size: 150.0,
                  color: Color.fromARGB(255, 15, 64, 86),
                ),
              ),
            ),
            Text(
              'Support Sphere',
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