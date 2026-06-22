import 'package:flutter/material.dart';

class ConfirmationDialog extends AlertDialog {
  const ConfirmationDialog({
    super.key,
    required super.actions,
    super.title = const Text('Are you sure?'),
    super.content = const Text('Would you like to confirm this action?'),
  });

  Future<T?> show<T>(BuildContext context) {
    return showDialog<T>(
      context: context,
      builder: (ctx) {
        return this;
      },
      barrierDismissible: false,
    );
  }
}
