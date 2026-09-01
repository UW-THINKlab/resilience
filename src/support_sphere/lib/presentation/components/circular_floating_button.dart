import 'package:flutter/material.dart';
import 'package:support_sphere/constants/color.dart' show ColorConstants;

class CircularFloatingButton extends StatelessWidget {
  const CircularFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: isActive ? ColorConstants.seed : Colors.white,
      elevation: 2,
      tooltip: tooltip,
      onPressed: onPressed,
      child: Icon(icon, color: isActive ? Colors.white : Colors.black),
    );
  }
}
