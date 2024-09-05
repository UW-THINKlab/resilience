import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/modal_edit.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Column(
        children: [
          Container(
            height: 50,
            child: const Center(
              // TODO: Add profile picture
              child: Text('User Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    });
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
        builder: (context) => ModalEdit(parentContext: context, title: title));
  }

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
    return const _ProfileSection(
      title: "Personal Information",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Name"),
            Text("John Doe"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Phone"),
            Text("+15555555555"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Email"),
            Text("johndoe@example.com"),
          ],
        ),
      ],
    );
  }
}

class _HouseholdInformation extends StatelessWidget {
  const _HouseholdInformation({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: ListView(shrinkWrap: true, children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Jane Doe"),
                Text("Adult"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Johnny Doe"),
                Text("Child"),
              ],
            ),
          ]),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Address"),
            Text("416 Example St."),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pets"),
            Text("2 Elderly Cats"),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Accessiblity Needs"),
            Text("None"),
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
            controller: TextEditingController()
              ..text = 'We are out of town this week.',
            expands: true,
            maxLines: null,
            readOnly: true,
            decoration:
                InputDecoration(filled: true, fillColor: Colors.grey[200]),
          ),
        )
      ],
    );
  }
}

class _ClusterInformation extends StatelessWidget {
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

class _PrivacyAndNotifications extends StatelessWidget {
  const _PrivacyAndNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileSection(
      displayTitle: false,
      children: [
        ListTile(
          title: Text("Privacy and Notifications"),
          trailing: Icon(Ionicons.chevron_forward_outline),
        ),
      ],
    );
  }
}
