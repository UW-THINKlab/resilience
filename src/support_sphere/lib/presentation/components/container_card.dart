import 'package:flutter/material.dart';

class ContainerCard extends StatelessWidget {
  const ContainerCard({super.key, this.child, this.color});

  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(15.0),
        child: child,
      ),
    );
  }
}
