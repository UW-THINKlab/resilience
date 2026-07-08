import 'package:flutter/material.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/confirmation_dialog.dart';

class ReauthDialog {
  late final ConfirmationDialog _confirmationDialog;
  final controller = TextEditingController();
  final BuildContext _context;
  ReauthDialog(this._context) {
    _confirmationDialog = ConfirmationDialog(
      actions: [
        CancelButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(_context),
        ),
        ConfirmButton(
          label: 'Continue',
          onPressed: () => Navigator.pop(_context, controller.text),
        ),
      ],
      title: Text('Confirm your password'),
      content: TextField(
        controller: controller,
        obscureText: true,
        onSubmitted: (_) => Navigator.pop(_context, controller.text),
        decoration: const InputDecoration(labelText: 'Current password'),
      ),
    );
  }

  Future<String?> show() {
    return _confirmationDialog.show<String>(_context);
  }

  Future<bool> perform(AuthService authService) async {
    final String? password = await show();
    if (password == null || password.isEmpty) return false;
    return await AuthService().reauthSignedInUser(password) != null;
  }
}
