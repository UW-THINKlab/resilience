import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/manage_users_cubit.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';

class ManageUsersBody extends StatelessWidget {
  const ManageUsersBody({super.key});

  @override
  Widget build(BuildContext context) {
    final MyAuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => ProfileCubit(authUser),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) => previous.cluster != current.cluster,
        builder: (context, profileState) {
          final String? clusterId = profileState.cluster?.id;
          if (clusterId == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocProvider(
            create: (context) => ManageUsersCubit(clusterId),
            child: const _ManageUsersContent(),
          );
        },
      ),
    );
  }
}

class _ManageUsersContent extends StatelessWidget {
  const _ManageUsersContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: const Center(
            child: Text(
              ManageUsersStrings.manageUsers,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ManageUsersCubit, ManageUsersState>(
            builder: (context, state) {
              if (state.clusterUsers.isEmpty) {
                return const Center(
                  child: Text(ManageUsersStrings.noUsers),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.clusterUsers.length,
                itemBuilder: (context, index) {
                  final clusterUser = state.clusterUsers[index];
                  return _ClusterUserCard(clusterUser: clusterUser);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClusterUserCard extends StatelessWidget {
  const _ClusterUserCard({required this.clusterUser});

  final ClusterUser clusterUser;

  @override
  Widget build(BuildContext context) {
    final String givenName = clusterUser.person.givenName;
    final String familyName = clusterUser.person.familyName;
    final String fullName = '$givenName $familyName'.trim();
    final String? userProfileId = clusterUser.person.profile?.id;

    return Card(
      child: ListTile(
        leading: Icon(
          clusterUser.isCaptain ? Icons.star : Icons.person,
          color: clusterUser.isCaptain ? Colors.amber : null,
        ),
        title: Text(fullName.isEmpty ? ManageUsersStrings.unknownUser : fullName),
        subtitle: Text(
          clusterUser.isCaptain
              ? ManageUsersStrings.clusterCaptain
              : ManageUsersStrings.regularUser,
        ),
        trailing: userProfileId != null
            ? _CaptainToggleButton(
                clusterUser: clusterUser,
                userProfileId: userProfileId,
              )
            : null,
      ),
    );
  }
}

class _CaptainToggleButton extends StatelessWidget {
  const _CaptainToggleButton({
    required this.clusterUser,
    required this.userProfileId,
  });

  final ClusterUser clusterUser;
  final String userProfileId;

  @override
  Widget build(BuildContext context) {
    return clusterUser.isCaptain
        ? TextButton(
            onPressed: () => _showConfirmDialog(
              context: context,
              title: ManageUsersStrings.revokeCaptainTitle,
              message: ManageUsersStrings.revokeCaptainMessage,
              confirmLabel: ManageUsersStrings.revoke,
              onConfirm: () =>
                  context.read<ManageUsersCubit>().revokeCaptain(userProfileId),
            ),
            child: const Text(
              ManageUsersStrings.revoke,
              style: TextStyle(color: Colors.red),
            ),
          )
        : TextButton(
            onPressed: () => _showConfirmDialog(
              context: context,
              title: ManageUsersStrings.grantCaptainTitle,
              message: ManageUsersStrings.grantCaptainMessage,
              confirmLabel: ManageUsersStrings.grant,
              onConfirm: () =>
                  context.read<ManageUsersCubit>().grantCaptain(userProfileId),
            ),
            child: const Text(ManageUsersStrings.grant),
          );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(ManageUsersStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}
