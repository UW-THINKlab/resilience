import 'package:flutter/material.dart';

class AppModeChangeDialog extends StatelessWidget {
  const AppModeChangeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Declare An Emergency'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('You are about to declare an emergency.'),
            Text('Would you like to declare an actual emergency or a test?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Test'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Emergency'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
