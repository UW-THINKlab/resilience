import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ModalEdit extends StatelessWidget {
  const ModalEdit(
      {super.key, required this.parentContext, required this.title, this.body});

  final String title;
  final Widget? body;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          actions: [
            IconButton(
              icon: const Icon(Ionicons.close_outline),
              onPressed: () => Navigator.pop(parentContext),
            ),
          ],
          title: Center(child: Text(title)),
        ),
        body: Container(),
      ),
    );
  }
}
