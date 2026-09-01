import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/presentation/components/people_select_list.dart';

/// Bottom-sheet form for editing a household's address/pets/accessibility
/// needs/notes and removing members. Used both by the profile page (editing
/// the current user's own household) and the cluster admin page (editing
/// any household in the cluster) - callers supply [onSave] to persist the
/// change in whatever way is appropriate for their context.
class EditHouseholdSheet extends StatefulWidget {
  const EditHouseholdSheet({
    super.key,
    this.household,
    this.members = const [],
    required this.onSave,
  });

  final Household? household;
  final List<Person> members;

  /// Called with the edited fields and the members that were deselected
  /// (to be removed from the household) when the form is submitted.
  final Future<void> Function({
    String? address,
    String? pets,
    String? accessibilityNeeds,
    String? notes,
    List<Person>? membersToRemove,
  }) onSave;

  @override
  State<EditHouseholdSheet> createState() => _EditHouseholdSheetState();
}

class _EditHouseholdSheetState extends State<EditHouseholdSheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final address = widget.household?.address ?? '';
    final pets = widget.household?.pets ?? '';
    final notes = widget.household?.notes ?? '';
    final accessibilityNeeds = widget.household?.accessibilityNeeds ?? '';
    final members = widget.members;
    List<Person> selectedMembers = [...members];

    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderTextField(
              name: 'address',
              decoration:
                  const InputDecoration(labelText: UserProfileStrings.address),
              initialValue: address,
            ),
            FormBuilderTextField(
              name: 'pets',
              decoration:
                  const InputDecoration(labelText: UserProfileStrings.pets),
              initialValue: pets,
            ),
            const SizedBox(height: 4),
            FormBuilderTextField(
              name: 'accessibilityNeeds',
              decoration: const InputDecoration(
                  labelText: UserProfileStrings.accessibilityNeeds),
              initialValue: accessibilityNeeds,
            ),
            const SizedBox(height: 4),
            PersonSelectorField(
              people: members,
              onConfirm: (l) {
                selectedMembers = l;
              },
              title: const Text('Edit household members'),
              buttonText: const Text(UserProfileStrings.removeMembersButton),
              initialValue: members,
            ),
            const SizedBox(height: 4),
            FormBuilderTextField(
              name: 'notes',
              decoration:
                  const InputDecoration(labelText: UserProfileStrings.notes),
              initialValue: notes,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  final formData = _formKey.currentState?.value;
                  if (formData != null) {
                    await widget.onSave(
                      address: formData['address'],
                      pets: formData['pets'],
                      accessibilityNeeds: formData['accessibilityNeeds'],
                      notes: formData['notes'],
                      membersToRemove: members
                          .where((m) => !selectedMembers.contains(m))
                          .toList(),
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  }
                }
              },
              child: const Text(UserProfileStrings.submit),
            ),
          ],
        ),
      ),
    );
  }
}
