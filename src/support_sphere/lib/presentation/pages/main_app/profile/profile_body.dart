import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/profile_section.dart';
import 'package:support_sphere/presentation/components/reauth_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/constants.dart';

String _initials(String? given, String? family) {
  final first = (given?.isNotEmpty ?? false) ? given![0].toUpperCase() : '';
  final last = (family?.isNotEmpty ?? false) ? family![0].toUpperCase() : '';
  return '$first$last';
}

/// Profile Body Widget
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final MyAuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => ProfileCubit(authUser),
      child: Column(
        children: [
          const _ProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: const [
                _PersonalInformation(),
                _HouseholdInformation(),
                _ClusterInformation(),
                _ActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) =>
          prev.userProfile != curr.userProfile ||
          prev.authUser != curr.authUser,
      builder: (context, state) {
        final givenName = state.userProfile?.givenName ?? '';
        final familyName = state.userProfile?.familyName ?? '';
        final fullName = '$givenName $familyName'.trim();
        final email = state.authUser?.email ?? '';
        final avatarInitials = _initials(givenName, familyName);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.35),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  avatarInitials.isEmpty ? '?' : avatarInitials,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? 'User' : fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConfirmButton(
                label: LoginStrings.logout,
                color: Colors.white,
                icon: const Icon(Icons.logout),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: const Text(LoginStrings.logout,
                    style: TextStyle(fontSize: 16)),
                onPressed: () => context
                    .read<AuthenticationBloc>()
                    .add(AuthOnLogoutRequested()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = value.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  isEmpty ? 'Not set' : value,
                  style: isEmpty
                      ? const TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonChipsRow extends StatelessWidget {
  const _PersonChipsRow({
    required this.people,
    required this.label,
    required this.icon,
  });

  final List<Person?> people;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                people.isEmpty
                    ? const Text(
                        'Not set',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: people.map((person) {
                          final given = person?.givenName ?? '';
                          final family = person?.familyName ?? '';
                          final name = '$given $family'.trim();
                          final chips = _initials(given, family);
                          return Chip(
                            avatar: CircleAvatar(
                              child: Text(
                                chips.isEmpty ? '?' : chips,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            label: Text(name.isEmpty ? 'Unknown' : name),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(2),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInformation extends StatelessWidget {
  const _PersonalInformation();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.userProfile != current.userProfile ||
          previous.authUser != current.authUser,
      builder: (context, state) {
        Person? userProfile = state.userProfile;
        MyAuthUser? authUser = state.authUser;
        final givenName = userProfile?.givenName ?? '';
        final familyName = userProfile?.familyName ?? '';
        final fullName = '$givenName $familyName'.trim();
        final phoneNumber = authUser?.phone ?? '';
        final email = authUser?.email ?? '';

        return ProfileSection(
          title: UserProfileStrings.personalInformation,
          state: state,
          modalBody: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'givenName',
                  decoration: const InputDecoration(
                      labelText: UserProfileStrings.givenName),
                  initialValue: givenName,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'familyName',
                  decoration: const InputDecoration(
                      labelText: UserProfileStrings.familyName),
                  initialValue: familyName,
                ),
                const SizedBox(height: 4),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(
                      labelText: UserProfileStrings.phone),
                  initialValue: phoneNumber,
                  validator: FormBuilderValidators.phoneNumber(
                      checkNullOrEmpty: false),
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
                  child: const Text(UserProfileStrings.submit),
                ),
              ],
            ),
          ),
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              label: UserProfileStrings.fullName,
              value: fullName,
            ),
            _InfoRow(
              icon: Icons.call_outlined,
              label: UserProfileStrings.phone,
              value: phoneNumber,
            ),
            _InfoRow(
              icon: Icons.mail_outline,
              label: UserProfileStrings.email,
              value: email,
            ),
          ],
        );
      },
    );
  }
}

class _HouseholdInformation extends StatelessWidget {
  const _HouseholdInformation();

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
            household?.houseHoldMembers?.members ?? <Person?>[];

        return ProfileSection(
          title: UserProfileStrings.householdInformation,
          state: state,
          modalBody: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'address',
                  decoration: const InputDecoration(
                      labelText: UserProfileStrings.address),
                  initialValue: address,
                ),
                const SizedBox(height: 4),
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
            _PersonChipsRow(
              people: householdMembers,
              label: UserProfileStrings.householdMembers,
              icon: Icons.people_outline,
            ),
            _InfoRow(
              icon: Icons.location_searching_outlined,
              label: UserProfileStrings.address,
              value: address,
            ),
            _InfoRow(
              icon: Icons.pets,
              label: UserProfileStrings.pets,
              value: pets,
            ),
            _InfoRow(
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

class _ClusterInformation extends StatelessWidget {
  const _ClusterInformation();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.cluster != current.cluster,
      builder: (context, state) {
        Cluster? cluster = state.cluster;
        final name = cluster?.name ?? '';
        final meetingPlace = cluster?.meetingPlace ?? '';
        final captains = cluster?.captains?.people ?? <Person?>[];

        return ProfileSection(
          title: UserProfileStrings.clusterInformation,
          readOnly: true,
          children: [
            _InfoRow(
              icon: Icons.home_outlined,
              label: UserProfileStrings.clusterName,
              value: name,
            ),
            _InfoRow(
              icon: Icons.location_searching_outlined,
              label: UserProfileStrings.meetingPlace,
              value: meetingPlace,
            ),
            _PersonChipsRow(
              people: captains,
              label: UserProfileStrings.captains,
              icon: Icons.gpp_good_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _ActionButtons extends StatefulWidget {
  const _ActionButtons();

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSection(
                title: UserProfileStrings.destructiveActions,
                readOnly: true,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      if (!await ReauthDialog(context).perform(AuthService()))
                        return;
                      if (!mounted) return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: const Text(UserProfileStrings.confirmPrompt),
                            content: const Text(
                                UserProfileStrings.confirmAccountDelete),
                            actions: [
                              CancelButton(
                                label: UserProfileStrings.deleteAccountCancel,
                                onPressed: () => Navigator.of(ctx).pop(false),
                              ),
                              ConfirmButton(
                                label: UserProfileStrings.deleteAccountConfirm,
                                color: ColorConstants.dangerRed,
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed == true && mounted) {
                        context
                            .read<AuthenticationBloc>()
                            .add(AuthDeleteMyUserRequested());
                      }
                    },
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                    label: const Text(
                      UserProfileStrings.deleteMyAccount,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
