import 'package:flutter/material.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/repositories/cluster.dart';

class ClusterMessageSheet extends StatefulWidget {
  final Cluster cluster;
  final String myProfileId;
  final VoidCallback onCancel;
  final void Function(String groupId, String groupName) onGroupCreated;

  const ClusterMessageSheet({
    super.key,
    required this.cluster,
    required this.myProfileId,
    required this.onCancel,
    required this.onGroupCreated,
  });

  @override
  State<ClusterMessageSheet> createState() => _ClusterMessageSheetState();
}

class _ClusterMessageSheetState extends State<ClusterMessageSheet> {
  final _chatRepo = ChatRepository();
  final _clusterRepo = ClusterRepository();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String>? _profileIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Cluster: ${widget.cluster.name ?? ''}';
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final ids = await _clusterRepo.getProfileIdsByClusterId(widget.cluster.id);
      if (mounted) setState(() => _profileIds = ids);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load members: $e')));
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileIds == null || _profileIds!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No members found in this cluster.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final groupId = await _chatRepo.createGroupWithProfiles(
        name: _nameController.text.trim(),
        createdByProfileId: widget.myProfileId,
        memberProfileIds: _profileIds!,
      );
      if (mounted) widget.onGroupCreated(groupId, _nameController.text.trim());
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create group: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final memberCount = _profileIds?.length;

    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message ${widget.cluster.name ?? 'cluster'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          if (_profileIds == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Text(
              '$memberCount member${memberCount == 1 ? '' : 's'} will be added to this group.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Please enter a group name' : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: (_isSaving || _profileIds == null) ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create group chat'),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
