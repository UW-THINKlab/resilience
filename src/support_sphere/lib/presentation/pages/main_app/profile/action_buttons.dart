import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/color.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/data/services/user_service.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/discreet_button.dart';
import 'package:support_sphere/presentation/components/profile_section.dart';
import 'package:support_sphere/presentation/components/reauth_dialog.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _blockListUnlocked = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
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
                      if (!await ReauthDialog(context).perform(_authService)) {
                        return;
                      }
                      if (!context.mounted) return;
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
                      if (confirmed == true && context.mounted) {
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
                  TextButton.icon(
                    onPressed: () async {
                      if (!await ReauthDialog(context).perform(_authService)) {
                        return;
                      }
                      setState(() {
                        _blockListUnlocked = true;
                      });
                    },
                    label: const Text(
                      UserProfileStrings.manageBlockedUsers,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    icon: const Icon(
                      Icons.block,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                  Visibility(
                    visible: _blockListUnlocked,
                    child: StreamBuilder(
                      stream: _userService
                          .blockedUsersStream(state.userProfile!.profile!.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        final List<People> data = snapshot.data!;
                        return ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          itemBuilder: (context, indx) {
                            return BlockedUserCard(
                              blockedPerson: data[indx],
                              unblock: () async {
                                if (await ReauthDialog(context)
                                    .perform(_authService)) {
                                  await _userService.unblockPerson(
                                    blockerId: state.userProfile!.profile!.id,
                                    blockeeId: data[indx].userProfileId!,
                                  );
                                  setState(() {});
                                }
                              },
                            );
                          },
                        );
                      },
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

class BlockedUserCard extends StatelessWidget {
  final People blockedPerson;
  final VoidCallback unblock;

  const BlockedUserCard({
    super.key,
    required this.blockedPerson,
    required this.unblock,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(blockedPerson.givenName ?? "unknown"),
      trailing: DiscreetButton(
        label: MessagesStrings.unblock,
        onPressed: unblock,
      ),
    );
  }
}
