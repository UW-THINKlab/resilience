import 'package:flutter/material.dart';

class ContainerCard extends StatelessWidget {
  const ContainerCard({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(15.0),
        child: child,
      ),
    );
  }
}
