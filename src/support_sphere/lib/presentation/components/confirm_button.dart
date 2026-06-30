import 'package:flutter/material.dart';
import 'package:support_sphere/constants/constants.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.child,
    this.icon,
    this.color,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  ButtonStyle get _style => ElevatedButton.styleFrom(
        backgroundColor: color ?? ColorConstants.confirmGreen,
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: padding,
        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      );

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: _style,
        icon: icon!,
        label: child ?? Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: _style,
      child: child ?? Text(label),
    );
  }
}
