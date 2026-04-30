import 'package:flutter/material.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/models/person.dart';

class CreateChatGroupSheet extends StatefulWidget {
  final ChatRepository repo;

  /// The current user's profile id (auth user id),
  /// i.e. `Person.profile.id` for the logged-in user.
  final String myProfileId;

  const CreateChatGroupSheet({
    super.key,
    required this.repo,
    required this.myProfileId,
  });

  @override
  State<CreateChatGroupSheet> createState() => _CreateChatGroupSheetState();
}

class _CreateChatGroupSheetState extends State<CreateChatGroupSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLoadingPeople = true;
  bool _isSaving = false;

  List<Person> _allPeople = [];
  final Set<String> _selectedProfileIds = {}; // profile.id (auth user id)

  @override
  void initState() {
    super.initState();
    _loadPeople();

    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadPeople() async {
    try {
      final people = await widget.repo.getSelectableChatPeople(
        excludeProfileId: widget.myProfileId,
      );

      if (!mounted) return;

      setState(() {
        _allPeople = people;
        _isLoadingPeople = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingPeople = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load people: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProfileIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final groupId = await widget.repo.createGroupWithProfiles(
        name: _nameController.text,
        description: _descriptionController.text,
        createdByProfileId: widget.myProfileId,
        memberProfileIds: _selectedProfileIds.toList(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(groupId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final filteredPeople = _allPeople.where((person) {
      final name = person.name().toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create chat group',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Please enter a group name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Members (${_selectedProfileIds.length} selected)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoadingPeople
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPeople.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: filteredPeople.length,
                          itemBuilder: (context, index) {
                            final person = filteredPeople[index];

                            // Should always be non-null due to .not('user_profile_id', 'is', null)
                            final profileId = person.profile?.id;
                            if (profileId == null) {
                              return const SizedBox.shrink();
                            }

                            final isSelected =
                                _selectedProfileIds.contains(profileId);

                            return CheckboxListTile(
                              value: isSelected,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(person.name()),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedProfileIds.add(profileId);
                                  } else {
                                    _selectedProfileIds.remove(profileId);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
