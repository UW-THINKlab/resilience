import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/inbox_cubit.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/messages_page.dart';
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/create_chat_group_sheet.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

const preloader = Center(child: CircularProgressIndicator());

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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Ionicons.chatbubbles_outline,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Inbox',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Ionicons.refresh_outline,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () => context.read<InboxCubit>().fetchGroups(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<InboxCubit, InboxState>(
              builder: (context, state) {
                if (state.isLoading) return preloader;

                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.warning_outline,
                            size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 12),
                        Text('Error: ${state.error}'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => context.read<InboxCubit>().fetchGroups(),
                          icon: const Icon(Ionicons.refresh_outline),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.chatbubbles_outline,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No conversations yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + to start a new chat group.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    final hasUnread = (group.unreadCount ?? 0) > 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            group.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          group.name,
                          style: hasUnread
                              ? const TextStyle(fontWeight: FontWeight.bold)
                              : null,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (group.lastMessage != null)
                              Text(
                                group.lastMessage!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: hasUnread ? null : Colors.grey,
                                  fontWeight: hasUnread ? FontWeight.w500 : null,
                                ),
                              ),
                            Text(
                              _formatTime(group.lastMessageTime),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        trailing: hasUnread
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  group.unreadCount.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                        onTap: () => _navigateToChat(context, group),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateGroupSheet(context),
        child: const Icon(Ionicons.add_outline),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }

  void _navigateToChat(BuildContext context, ChatGroup group) async {
    print('🧭 Navigating to: ${group.id}'); // ✅ Verify source
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(group.id, DateTime.now().toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          groupId: group.id,
          groupName: group.name,
        ),
      ),
    );
  }

  Future<void> _openCreateGroupSheet(BuildContext context) async {
    // final authState = context.read<AuthenticationBloc>().state;
    // final currentUser = authState.user;

    final myProfileId = context.read<AuthenticationBloc>().state.user.uuid;
    final chatRepo = ChatRepository();

    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateChatGroupSheet(
        repo: chatRepo,
        myProfileId: myProfileId,
      ),
    );

    if (result != null && context.mounted) {
      await context.read<InboxCubit>().fetchGroups();

      if (!context.mounted) return;

      final (groupId, groupName) = result;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(groupId, DateTime.now().toString());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessagesPage(groupId: groupId, groupName: groupName),
        ),
      );
    }
  }
}
