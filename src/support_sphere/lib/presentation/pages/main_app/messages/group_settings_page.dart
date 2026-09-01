import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/data/services/user_service.dart';

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage({super.key, required this.group});
  final ChatGroup group;

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState(group);
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ChatGroup group;

  _GroupSettingsPageState(this.group);

  Future<void> _addMember() async {
    // TODO: implement add member for #306
  }

  Future<void> _removeMember(String memberId, String displayName) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.person_remove_alt_1_outlined),
          title: const Text('Remove member?'),
          content: Text(
            'Remove $displayName from this group? They will no longer have access to group conversations.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldRemove != true) {
      return;
    }
    // TODO: remove member for #306
  }

  Future<void> _save() async {
    // TODO: implement save for #306
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group settings'),
        actions: [
          IconButton(
            tooltip: 'Save changes',
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'General',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FormBuilderTextField(
                    name: 'name',
                    initialValue: widget.group.name,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      prefixIcon: Icon(Icons.groups_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a group name.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Members (${group.members.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add user',
                    onPressed: _addMember,
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: group.members.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final memberId = group.members[index];

                    return MemberTile(
                      memberId: memberId,
                      onRemove: (displayName) {
                        _removeMember(memberId, displayName);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text('Save changes'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemberTile extends StatelessWidget {
  final UserService userService = UserService();
  final Function onRemove;
  MemberTile({super.key, required this.memberId, required this.onRemove});

  final String memberId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<dynamic>(
      future: userService.personByProfileId(memberId),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        final person = snapshot.data;
        final name = person?.givenName?.toString().trim();
        final displayName = name == null || name.isEmpty
            ? 'Unknown user'
            : name;

        final initial = displayName == 'Unknown user'
            ? '?'
            : displayName.substring(0, 1).toUpperCase();

        return ListTile(
          contentPadding: const EdgeInsets.only(left: 16, right: 8),
          leading: CircleAvatar(
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(initial),
          ),
          title: Text(
            isLoading ? 'Loading member…' : displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: hasError
              ? Text(
                  'Could not load details',
                  style: TextStyle(color: colorScheme.error),
                )
              : Text(
                  'Profile ID: $memberId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          trailing: IconButton(
            tooltip: 'Remove $displayName',
            onPressed: () => onRemove(displayName),
            icon: const Icon(Icons.close),
            color: colorScheme.error,
          ),
        );
      },
    );
  }
}
