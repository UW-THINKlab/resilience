import 'dart:developer' as developer;
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/models/messages.dart';

class ChatRepository {
  Future<List<ChatGroup>> getUserChatGroups(String userId) async {
    developer.log(
      'getUserChatGroups() called for userId=$userId',
      name: 'ChatRepository',
    );
    final prefs = await SharedPreferences.getInstance();
    final MessagesRepository messageRepo = MessagesRepository();
    final response = await supabase.from('group_members').select('''
          groups(
            id, 
            name,
            description
          )
        ''').eq('profile_id', userId);

    print('Got response: ${response}');

    final groups = response.map((item) {
      final json =
          item['groups'] ?? item; // Flatten json- response comes out nested
      return ChatGroup.fromJson(json);
    }).toList();

    developer.log(
      'getUserChatGroups() parsed ${groups.length} groups',
      name: 'ChatRepository',
    );
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    
    for (ChatGroup group in groups) {
      group.lastMessageTime = await DateTime.parse(prefs.getString(group.id) ?? epoch.toString());
      group.unreadCount = await messageRepo.unreadCount(group.id, group.lastMessageTime.toString());
      group.lastMessage = await messageRepo.lastUnreadMessage(userId, group.id, group.lastMessageTime.toString());
    }

    return groups;
    //TODO implement:
    // id, name, last_message, last_message_time, unread_count
  }

// Create new chat group with member profile IDs. Returns new group ID.
  Future<String> createGroupWithProfiles({
    required String name,
    String? description,
    required String createdByProfileId,
    required List<String> memberProfileIds,
  }) async {
    final cleanName = name.trim();
    final cleanDescription =
        (description?.trim().isEmpty ?? true) ? null : description!.trim();

    // Ensure creator is included and uniqueness
    final allProfileIds = {
      createdByProfileId,
      ...memberProfileIds,
    }.toList();

    developer.log(
      'createGroupWithProfiles() name="$cleanName", '
      'createdByProfileId=$createdByProfileId, '
      'memberCount=${allProfileIds.length}',
      name: 'ChatRepository',
    );

    // groups.created_by should be a profile id (auth user id)
    final insertedGroup = await supabase
        .from('groups')
        .insert({
          'name': cleanName,
          'description': cleanDescription,
          'created_by_id': createdByProfileId,
        })
        .select('id')
        .single();

    final groupId = insertedGroup['id'] as String;

    developer.log(
      'createGroupWithProfiles() inserted groupId=$groupId',
      name: 'ChatRepository',
    );

    final memberRows = allProfileIds.map((profileId) {
      return {
        'group_id': groupId,
        'profile_id': profileId, // profile.id == auth user id
      };
    }).toList();

    developer.log(
      'createGroupWithProfiles() inserting member rows: $memberRows',
      name: 'ChatRepository',
    );

    await supabase.from('group_members').insert(memberRows);

    return groupId;
  }

//TODO Later- change this function out for Paul's
  Future<List<Person>> getSelectableChatPeople({
    required String excludeProfileId,
  }) async {
    developer.log(
      'getSelectableChatPeople() excluding profileId=$excludeProfileId',
      name: 'ChatRepository',
    );

    final response = await supabase
        .from('people')
        .select('''
          id,
          given_name,
          family_name,
          nickname,
          is_safe,
          needs_help,
          user_profile_id
        ''')
        .not('user_profile_id', 'is', null)
        .neq('user_profile_id', excludeProfileId)
        .order('given_name');

    final list = (response as List)
        .map((row) => Person.fromJson(row as Map<String, dynamic>))
        .toList();

    developer.log(
      'getSelectableChatPeople() got ${list.length} people',
      name: 'ChatRepository',
    );

    return list;
  }
}
