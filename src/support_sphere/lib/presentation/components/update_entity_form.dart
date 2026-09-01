import 'package:flutter/material.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';

/// Shared chrome for "update `<entity>`" dialogs (Card, title, close button,
/// Cancel/Confirm row). Callers supply the entity-specific form [fields] and
/// an [onConfirm] callback that validates/persists and returns whether the
/// dialog should close.
class UpdateEntityForm extends StatefulWidget {
  const UpdateEntityForm({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.fields,
    required this.onConfirm,
    this.formKey,
  });

  final String title;
  final String confirmLabel;
  final List<Widget> fields;

  /// Returns true to close the dialog, false to keep it open
  /// (e.g. form validation failed).
  final Future<bool> Function() onConfirm;

  final GlobalKey<FormState>? formKey;

  @override
  State<UpdateEntityForm> createState() => _UpdateEntityFormState();
}

class _UpdateEntityFormState extends State<UpdateEntityForm> {
  late final GlobalKey<FormState> _formKey =
      widget.formKey ?? GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            margin: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                          child: Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                      Positioned(
                        right: -12,
                        top: -12,
                        child: IconButton(
                          icon: const Icon(Icons.cancel,
                              size: 32, color: Colors.black54),
                          tooltip: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...widget.fields,
                  const SizedBox(height: 50),
                  // Buttons to Confirm or Cancel
                  Row(children: [
                    CancelButton(
                      label: 'Cancel',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    ConfirmButton(
                      label: widget.confirmLabel,
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              setState(() => _isSaving = true);
                              final success = await widget.onConfirm();
                              if (mounted) {
                                setState(() => _isSaving = false);
                                if (success) navigator.pop();
                              }
                            },
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ]),
                ],
              ),
            )));
  }
}
