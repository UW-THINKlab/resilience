import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';

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

class _ProfileSection extends StatelessWidget {
  const _ProfileSection(
      {super.key,
      this.title = "Section Header",
      this.children = const [],
      this.displayTitle = true,
      this.readOnly = false});

  final String title;
  final List<Widget> children;
  final bool displayTitle;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _getTitle(context) ?? const SizedBox(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<dynamic> _showModalBottomSheet(BuildContext context) {
    return showCupertinoModalBottomSheet(
        expand: true,
        context: context,

        /// TODO: Implement Edit modal
        builder: (context) => Container());
  }

  /// Get the title of the section
  /// If the title is not displayed, return null
  /// If the title is displayed, return a ListTile with the title and an edit icon
  /// If the section is read only, don't show the edit icon
  /// If the section is not read only, show the edit icon
  Widget? _getTitle(BuildContext context) {
    if (displayTitle) {
      // return Center(child: Text(title));
      return ListTile(
        title: Text(title),
        trailing: readOnly
            ? null
            : GestureDetector(
                onTap: () => _showModalBottomSheet(context),
                child: const Icon(Ionicons.create_outline),
              ),
      );
    }
    return null;
  }
}

class _PersonalInformation extends StatelessWidget {
  const _PersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.userProfile != current.userProfile,
      builder: (context, state) {
        Person? userProfile = state.userProfile;
        AuthUser? authUser = state.authUser;
        String givenName = userProfile?.givenName ?? '';
        String familyName = userProfile?.familyName ?? '';
        String fullName = '$givenName $familyName';
        String phoneNumber = authUser?.phone ?? '';
        String email = authUser?.email ?? '';
        return _ProfileSection(
          title: "Personal Information",
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
        );
      },
    );
  }
}

class _HouseholdInformation extends StatelessWidget {
  const _HouseholdInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.household != current.household,
      builder: (context, state) {
        Household? household = state.household;
        String address = household?.address ?? '';
        String pets = household?.pets ?? '';
        String notes = household?.notes ?? '';
        String accessibilityNeeds = household?.accessibility_needs ?? 'None';
        List<Person?> householdMembers =
            household?.houseHoldMembers?.members ?? [];
        List<String> members = householdMembers.map((person) {
          String givenName = person?.givenName ?? '';
          String familyName = person?.familyName ?? '';
          String fullName = '$givenName $familyName';
          return fullName;
        }).toList();
        return _ProfileSection(
          title: "Household Information",
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
                Text(accessibilityNeeds),
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
    // Cluster Information
    return _ProfileSection(
      title: "Cluster Information",
      readOnly: true,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Name"),
            Text("Cluster 1"),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Meeting place"),
            Text("410 Example Street"),
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
          child: ListView(shrinkWrap: true, children: const [
            Text("Jane Smith"),
            Text("John Smith"),
          ]),
        ),
      ],
    );
  }
}
