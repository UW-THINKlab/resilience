import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/constants.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/edit_household_sheet.dart';
import 'package:support_sphere/presentation/components/profile_section.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/add_house_hold_members_button.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/info_row.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/person_chips_row.dart';

class HouseholdInformation extends StatelessWidget {
  const HouseholdInformation({super.key});

  @override
  Widget build(BuildContext context) {
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

        return ProfileSection(
          title: UserProfileStrings.householdInformation,
          state: state,
          modalBody: EditHouseholdSheet(
            household: household,
            members: householdMembers,
            onSave: (
                {address, pets, accessibilityNeeds, notes, membersToRemove}) async {
              if (household == null) return;
              await context.read<ProfileCubit>().saveHouseholdInfoModal(
                    householdId: household.id,
                    address: address,
                    pets: pets,
                    accessibilityNeeds: accessibilityNeeds,
                    notes: notes,
                    membersToRemove: membersToRemove,
                  );
            },
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
            AddHouseHoldMembersButton(
              currentHouseholdMembers: householdMembers,
              householdId: household?.id ?? '',
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
