import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/utils/reservation_status_colors.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/inbox_cubit.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/messages_page.dart';
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/create_chat_group_sheet.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/repositories/message.dart';

///TODO- make sure preloader is the same across all pages, potentially move to a shared widget?
const preloader =
    Center(child: CircularProgressIndicator(color: Colors.blueGrey));

final log = Logger('Message Groups Page');
final MessagesRepository messageRepo = MessagesRepository();

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});
  // Source - https://stackoverflow.com/a/51901311
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InboxCubit(context.read<AuthenticationBloc>().state.user),
      child: const InboxView(),
    );
  }
}

class InboxView extends StatelessWidget {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InboxCubit>().fetchGroups(),
          ),
        ],
      ),
      body: BlocBuilder<InboxCubit, InboxState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  ElevatedButton(
                    onPressed: () => context.read<InboxCubit>().fetchGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.groups.isEmpty) {
            return const Center(child: Text('No chat groups'));
          }

          return ListView.builder(
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return Slidable(
                key: ValueKey(group.id),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        await context.read<InboxCubit>().deleteGroup(group.id);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'delete',
                    ),
                  ],
                ),
                child: Card(
                  color: _cardColor(group),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: switch (group.type) {
                      GROUP_CHAT_TYPE.request_consumable => CircleAvatar(
                          backgroundColor: Colors.blue[300],
                          child: const FaIcon(FontAwesomeIcons.glassWater,
                              color: Colors.white),
                        ),
                      GROUP_CHAT_TYPE.request_durable => CircleAvatar(
                          backgroundColor: Colors.yellow[600],
                          child: const FaIcon(FontAwesomeIcons.wrench,
                              color: Colors.white),
                        ),
                      GROUP_CHAT_TYPE.request_skill => CircleAvatar(
                          backgroundColor: Colors.green[400],
                          child: const FaIcon(FontAwesomeIcons.helmetSafety,
                              color: Colors.white),
                        ),
                      GROUP_CHAT_TYPE.chat => CircleAvatar(
                          child: Text(chatAvatarText(group)),
                        ),
                    },
                    title: Text(group.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: group.unreadCount > 0
                        ? Badge(
                            label: Text(group.unreadCount.toString()),
                            child: const Icon(Icons.circle),
                          )
                        : null,
                    onTap: () => _navigateToChat(context, group),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateGroupSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String chatAvatarText(ChatGroup group) {
    if (group.name.isEmpty) return '[]';
    return group.name[0].toUpperCase();
  }

  Color? _cardColor(ChatGroup group) {
    final baseColor = group.type.baseColor;
    if (baseColor == null) return null;

    final isNewRequest = group.reservationStatus == null ||
        group.reservationStatus == RESERVATION_STATUS.pending;
    if (isNewRequest) {
      return group.isRequester ? baseColor[100] : baseColor[50];
    }

    return group.reservationStatus!.statusColor(isRequester: group.isRequester);
  }

  void _navigateToChat(BuildContext context, ChatGroup group) async {
    log.fine('🧭 Navigating to: ${group.id}'); // ✅ Verify source
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(group: group),
      ),
    );
    if (!context.mounted) return;
    await context.read<InboxCubit>().fetchGroups();
  }

  Future<void> _openCreateGroupSheet(BuildContext context) async {
    // final authState = context.read<AuthenticationBloc>().state;
    // final currentUser = authState.user;

    final myProfileId = context.read<AuthenticationBloc>().state.user.uuid;
    final chatRepo = ChatRepository();

    final chatGroup = await showModalBottomSheet<ChatGroup>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateChatGroupSheet(
        repo: chatRepo,
        myProfileId: myProfileId,
      ),
    );

    if (chatGroup != null && context.mounted) {
      await context.read<InboxCubit>().fetchGroups();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessagesPage(group: chatGroup),
          ),
        );
      }
    }
  }
}

extension _GroupChatTypeColor on GROUP_CHAT_TYPE {
  static const Map<GROUP_CHAT_TYPE, MaterialColor?> _baseColors = {
    GROUP_CHAT_TYPE.request_consumable: Colors.blue,
    GROUP_CHAT_TYPE.request_durable: Colors.yellow,
    GROUP_CHAT_TYPE.request_skill: Colors.green,
    GROUP_CHAT_TYPE.chat: null,
  };

  MaterialColor? get baseColor => _baseColors[this];
}
