import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/inbox_cubit.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/messages_page.dart';
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/presentation/pages/main_app/messages/create_chat_group_sheet.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          if (state.isLoading)
            return const Center(child: CircularProgressIndicator());

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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(group.name[0].toUpperCase()),
                  ),
                  title: Text(group.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (group.lastMessage != null)
                          Text(
                            group.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: group.unreadCount! > 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        Text(
                          _formatTime(group.lastMessageTime),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: group.unreadCount! > 0
                        ? Badge(
                      label: Text(group.unreadCount.toString()),
                      child: const Icon(Icons.circle),
                    )
                        : null,
                  onTap: () => _navigateToChat(context, group),
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
