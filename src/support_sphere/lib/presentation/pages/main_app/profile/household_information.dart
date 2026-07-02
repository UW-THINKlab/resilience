import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:support_sphere/constants/constants.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/people_select_list.dart';
import 'package:support_sphere/presentation/components/profile_section.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/info_row.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/person_chips_row.dart';

class HouseholdInformation extends StatelessWidget {
  const HouseholdInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.household != current.household,
      builder: (context, state) {
        Household? household = state.household;
        final inviteCode = state.inviteCode ?? '';
        final address = household?.address ?? '';
        final pets = household?.pets ?? '';
        final notes = household?.notes ?? '';
        final accessibilityNeeds = household?.accessibilityNeeds ?? '';
        final householdMembers =
            (household?.houseHoldMembers?.members ?? <Person?>[])
                .where((p) => p != null)
                .map((p) => p!)
                .toList();

        List<Person> selectedMembers = [...householdMembers];

        return ProfileSection(
          title: UserProfileStrings.householdInformation,
          state: state,
          modalBody: FormBuilder(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'address',
                    decoration: const InputDecoration(
                        labelText: UserProfileStrings.address),
                    initialValue: address,
                  ),
                  //const SizedBox(height: 4),
                  FormBuilderTextField(
                    name: 'pets',
                    decoration: const InputDecoration(
                        labelText: UserProfileStrings.pets),
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
                    people: householdMembers,
                    onConfirm: (l) {
                      selectedMembers = l;
                    },
                    title: const Text('Edit household members'),
                    buttonText: const Text('Edit members'),
                    initialValue: householdMembers,
                  ),
                  const SizedBox(height: 4),
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: const InputDecoration(
                        labelText: UserProfileStrings.notes),
                    initialValue: notes,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        final formData = formKey.currentState?.value;
                        if (formData != null && household != null) {
                          context.read<ProfileCubit>().saveHouseholdInfoModal(
                                householdId: household.id,
                                address: formData['address'],
                                pets: formData['pets'],
                                accessibilityNeeds:
                                    formData['accessibilityNeeds'],
                                notes: formData['notes'],
                                membersToRemove: householdMembers
                                    .where((m) => !selectedMembers.contains(m))
                                    .toList(),
                              );
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text(UserProfileStrings.submit),
                  ),
                ],
              ),
            ),
          ),
          children: [
            // Invite code with copy button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.key_outlined,
                        size: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Code',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  inviteCode.isEmpty ? 'Not set' : inviteCode,
                                  style: inviteCode.isEmpty
                                      ? const TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic)
                                      : const TextStyle(
                                          fontFamily: 'monospace',
                                          letterSpacing: 1.5,
                                          fontSize: 13,
                                        ),
                                ),
                              ),
                            ),
                            if (inviteCode.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.copy_outlined, size: 16),
                                tooltip: 'Copy invite code',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: inviteCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invite code copied!')),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PersonChipsRow(
              people: householdMembers,
              label: UserProfileStrings.householdMembers,
              icon: Icons.people_outline,
            ),
            InfoRow(
              icon: Icons.location_searching_outlined,
              label: UserProfileStrings.address,
              value: address,
            ),
            InfoRow(
              icon: Icons.pets,
              label: UserProfileStrings.pets,
              value: pets,
            ),
            InfoRow(
              icon: Icons.accessibility,
              label: UserProfileStrings.accessibilityNeeds,
              value: accessibilityNeeds,
            ),
            // Notes as plain text (not a text field)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child:
                        Icon(Icons.article, size: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserProfileStrings.notes,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notes.isEmpty ? 'Not set' : notes,
                          style: notes.isEmpty
                              ? const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
