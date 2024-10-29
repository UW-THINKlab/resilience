import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/profile_section.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Profile Body Widget
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => ProfileCubit(authUser),
      child: LayoutBuilder(builder: (context, constraint) {
        return Column(
          children: [
            Container(
              height: 50,
              child: const Center(
                // TODO: Add profile picture
                child: Text('User Profile',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                padding: const EdgeInsets.all(10),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: const [
                    // Personal Information
                    _PersonalInformation(),
                    // Household Information
                    _HouseholdInformation(),
                    // Cluster Information
                    _ClusterInformation(),
                    // TODO: Add Privacy and Notifications
                    // Privacy and Notifications
                    // _PrivacyAndNotifications(),
                    // Log Out Button
                    _LogOutButton(),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton.icon(
            onPressed: () =>
                context.read<AuthenticationBloc>().add(AuthOnLogoutRequested()),
            icon: const Icon(Ionicons.log_out_outline),
            label: const Text('Log Out'),
          ),
        );
      },
    );
  }
}

class _PersonalInformation extends StatelessWidget {
  const _PersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.userProfile != current.userProfile ||
          previous.authUser != current.authUser,
      builder: (context, state) {
        Person? userProfile = state.userProfile;
        AuthUser? authUser = state.authUser;
        String givenName = userProfile?.givenName ?? '';
        String familyName = userProfile?.familyName ?? '';
        String fullName = '$givenName $familyName';
        String phoneNumber = authUser?.phone ?? '';
        String email = authUser?.email ?? '';

        return ProfileSection(
          title: "Personal Information",
          state: state,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Name"),
                Text(fullName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phone"),
                Text(phoneNumber),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Email"),
                Text(email),
              ],
            ),
          ],
          modalBody: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'givenName',
                  decoration: const InputDecoration(labelText: 'Given Name'),
                  initialValue: givenName,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'familyName',
                  decoration: const InputDecoration(labelText: 'Family Name'),
                  initialValue: familyName,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(labelText: 'Phone'),
                  initialValue: phoneNumber,
                  validator: FormBuilderValidators.phoneNumber(
                      checkNullOrEmpty: false),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = formKey.currentState?.value;

                      if (formData != null && userProfile != null) {
                        context.read<ProfileCubit>().savePersonalInfoModal(
                              personId: userProfile.id,
                              givenName: formData['givenName'],
                              familyName: formData['familyName'],
                              phone: formData['phone'],
                            );
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HouseholdInformation extends StatelessWidget {
  const _HouseholdInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.household != current.household,
      builder: (context, state) {
        Household? household = state.household;
        String address = household?.address ?? '';
        String pets = household?.pets ?? '';
        String notes = household?.notes ?? '';
        String accessibilityNeeds = household?.accessibility_needs ?? '';
        List<Person?> householdMembers =
            household?.houseHoldMembers?.members ?? [];
        List<String> members = householdMembers.map((person) {
          String givenName = person?.givenName ?? '';
          String familyName = person?.familyName ?? '';
          String fullName = '$givenName $familyName';
          return fullName;
        }).toList();

        return ProfileSection(
          title: "Household Information",
          state: state,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Household Members"),
              ],
            ),
            Container(
              height: 50.0,
              child: ListView(shrinkWrap: true, children: [
                for (var member in members)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(member),
                    ],
                  ),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Address"),
                Text(address),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pets"),
                Text(pets),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Accessiblity Needs"),
                Text(accessibilityNeeds.isEmpty ? "None" : accessibilityNeeds),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notes (visible to cluster captain(s))"),
              ],
            ),
            Container(
              height: 50,
              child: TextField(
                controller: TextEditingController()..text = notes,
                expands: true,
                maxLines: null,
                readOnly: true,
                decoration:
                    InputDecoration(filled: true, fillColor: Colors.grey[200]),
              ),
            )
          ],
          modalBody: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'address',
                  decoration: const InputDecoration(labelText: 'Address'),
                  initialValue: address,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'pets',
                  decoration: const InputDecoration(labelText: 'Pets'),
                  initialValue: pets,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'accessibilityNeeds',
                  decoration:
                      const InputDecoration(labelText: 'Accessibility Needs'),
                  initialValue: accessibilityNeeds,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'notes',
                  decoration: const InputDecoration(labelText: 'Notes'),
                  initialValue: notes,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = formKey.currentState?.value;

                      if (formData != null && household != null) {
                        context.read<ProfileCubit>().saveHouseholdInfoModal(
                              householdId: household.id,
                              address: formData['address'],
                              pets: formData['pets'],
                              accessibilityNeeds: formData['accessibilityNeeds'],
                              notes: formData['notes'],
                            );
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Cluster Information
class _ClusterInformation extends StatelessWidget {
  /// TODO: Add cluster information from database
  const _ClusterInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.cluster != current.cluster,
      builder: (context, state) {
        Cluster? cluster = state.cluster;
        String name = cluster?.name ?? '';
        String meetingPlace = cluster?.meetingPlace ?? '';
        List<Person?> captains = cluster?.captains?.people ?? [];
        List<String> captainsNames = captains.map((captain) {
          String givenName = captain?.givenName ?? '';
          String familyName = captain?.familyName ?? '';
          String fullName = '$givenName $familyName';
          return fullName;
        }).toList();
        return ProfileSection(
          title: "Cluster Information",
          readOnly: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Name"),
                Text(name),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Meeting place"),
                Text(meetingPlace),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Captain(s)"),
              ],
            ),
            Container(
              height: 50.0,
              child: ListView(
                shrinkWrap: true,
                children: captainsNames.map((n) => Text(n)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
