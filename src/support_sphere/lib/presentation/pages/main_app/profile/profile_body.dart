import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/profile_section.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/constants.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/action_buttons.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/household_information.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/info_row.dart';
import 'package:support_sphere/presentation/pages/main_app/profile/person_chips_row.dart';

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
                HouseholdInformation(),
                _ClusterInformation(),
                ActionButtons(),
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
        final avatarInitials = state.userProfile?.initials() ?? '';

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
            InfoRow(
              icon: Icons.person_outline,
              label: UserProfileStrings.fullName,
              value: fullName,
            ),
            InfoRow(
              icon: Icons.call_outlined,
              label: UserProfileStrings.phone,
              value: phoneNumber,
            ),
            InfoRow(
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
            InfoRow(
              icon: Icons.home_outlined,
              label: UserProfileStrings.clusterName,
              value: name,
            ),
            InfoRow(
              icon: Icons.location_searching_outlined,
              label: UserProfileStrings.meetingPlace,
              value: meetingPlace,
            ),
            PersonChipsRow(
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
