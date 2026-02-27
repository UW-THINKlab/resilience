import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/user_role_record.dart';
import 'package:support_sphere/logic/cubit/manage_user_roles_cubit.dart';

class ManageUserRolesBody extends StatelessWidget {
  const ManageUserRolesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageUserRolesCubit(),
      child: const _ManageUserRolesView(),
    );
  }
}

class _ManageUserRolesView extends StatelessWidget {
  const _ManageUserRolesView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Text(
              ManageUserRolesStrings.pageTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Expanded(child: _UserRolesList()),
      ],
    );
  }
}

class _UserRolesList extends StatelessWidget {
  const _UserRolesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageUserRolesCubit, ManageUserRolesState>(
      builder: (context, state) {
        if (state.users.isEmpty) {
          return const Center(child: Text(ManageUserRolesStrings.noUsers));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];
            return _UserRoleTile(user: user);
          },
        );
      },
    );
  }
}

class _UserRoleTile extends StatelessWidget {
  const _UserRoleTile({required this.user});

  final UserRoleRecord user;

  bool get _isSubcomAgent => user.role == AppRoles.subcommunityAgent;

  /// Only allow toggling for users that are USER or SUBCOM_AGENT role.
  bool get _canToggle =>
      user.role == AppRoles.user || user.role == AppRoles.subcommunityAgent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.displayName),
        subtitle: Text('${ManageUserRolesStrings.currentRole}: ${user.role}'),
        trailing: _canToggle
            ? Switch(
                value: _isSubcomAgent,
                onChanged: (value) =>
                    _onRoleToggled(context, user, value),
              )
            : null,
      ),
    );
  }

  Future<void> _onRoleToggled(
      BuildContext context, UserRoleRecord user, bool grant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          grant
              ? ManageUserRolesStrings.confirmGrant
              : ManageUserRolesStrings.confirmRevoke,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(ManageUserRolesStrings.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(ManageUserRolesStrings.buttonConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (grant) {
        context
            .read<ManageUserRolesCubit>()
            .grantSubcomAgentRole(user.userProfileId);
      } else {
        context
            .read<ManageUserRolesCubit>()
            .revokeSubcomAgentRole(user.userProfileId);
      }
    }
  }
}
