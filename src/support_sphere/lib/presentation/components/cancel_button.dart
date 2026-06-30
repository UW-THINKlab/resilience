import 'package:flutter/material.dart';
import 'package:support_sphere/constants/constants.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // return ElevatedButton(
    //   onPressed: onPressed,
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: ColorConstants.cancelGray,
    //     foregroundColor: Colors.black87,
    //     elevation: 2,
    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    //     shape: const StadiumBorder(),
    //   ),
    //   child: Text(label),
    // );
    return TextButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
