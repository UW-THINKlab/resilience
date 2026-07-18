import 'dart:developer' as developer;
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/services/resource_service.dart';

class ChatRepository {
  Future<List<ChatGroup>> getUserChatGroups(String userId) async {
    developer.log(
      'getUserChatGroups() called for userId=$userId',
      name: 'ChatRepository',
    );

    final response = await supabase.from('groups').select('''
      id,
      name,
      description,
      type,
      created_at,
      group_members(
        profile_id,
        user_profiles(
          people(
            given_name,
            user_profile_id
          )
        )
      )
    ''').withConverter(
      (resp) => resp.map((element) {
        List<Map<String, dynamic>> members = (element['group_members'] as List)
            .map((e) => (e as Map<String, dynamic>)['user_profiles']['people']
                as Map<String, dynamic>)
            .toList();
        return (
          group: Groups.fromJson(element),
          members: People.converter(members),
          createdAt: DateTime.parse(element['created_at'] as String),
        );
      }).toList(),
    );
    log.fine('Got response: $response');

    final messageRepo = MessagesRepository();
    final resourceService = ResourceService();
    final groupsWithTimestamps = await response
        .where((row) => isUserIdInList(userId, row.members))
        .map((row) async {
          final chatGroupFuture = responseToChatGroup(
              (group: row.group, members: row.members), userId);
          final lastMessageAtFuture = messageRepo.lastMessageSentAt(row.group.id);
          final reservationFuture = row.group.type == GROUP_CHAT_TYPE.chat
              ? Future<List<Map<String, dynamic>>>.value(const [])
              : resourceService.getPendingReservationForChat(
                  groupId: row.group.id);
          final chatGroup = await chatGroupFuture;
          final lastMessageAt = await lastMessageAtFuture;
          final reservationRows = await reservationFuture;
          final reservation = reservationRows.isEmpty
              ? null
              : ResourceReservations.fromJson(reservationRows.first);
          RESERVATION_STATUS? effectiveStatus;
          bool isRequester;
          if (reservation != null) {
            effectiveStatus = reservation.status;
            isRequester = reservation.requesterProfileId == userId;
          } else if (row.group.type != GROUP_CHAT_TYPE.chat &&
              await messageRepo.hasResourceRemovedMessage(row.group.id)) {
            // Reservation was cascade-deleted along with its user_resource;
            // treat the group the same as a released request so it colors
            // and hides action buttons the same way.
            effectiveStatus = RESERVATION_STATUS.released;
            isRequester = true;
          } else {
            effectiveStatus = null;
            isRequester = false;
          }
          final chatGroupWithStatus = chatGroup.copyWith(
            reservationStatus: effectiveStatus,
            isRequester: isRequester,
          );
          return (
            chatGroup: chatGroupWithStatus,
            sortKey: lastMessageAt ?? row.createdAt
          );
        })
        .wait;

    groupsWithTimestamps.sort((a, b) => b.sortKey.compareTo(a.sortKey));

    return groupsWithTimestamps.map((row) => row.chatGroup).toList();
  }

  // TODO: remove this method after confirming supabase will return valid chats only
  //  And/or modifying the query to include chats that belong to current user only.
  bool isUserIdInList(String uid, List<People> list) {
    return list.any((p) => p.userProfileId == uid);
  }

  Future<ChatGroup> responseToChatGroup(
      ({Groups group, List<People> members}) response, String uid) async {
    final MessagesRepository messageRepo = MessagesRepository();
    final group = response.group;
    final members = response.members;
    final lastMessage = await messageRepo.lastUnreadMessage(group.id);
    final unreadCount = await messageRepo.unreadCount(group.id, uid);
    return ChatGroup.from(
      group.id,
      group.name,
      description: group.description,
      type: group.type,
      lastMessage: lastMessage,
      members: members.map((e) => e.userProfileId ?? '').toList(),
      unreadCount: unreadCount,
    );
  }

// Create new chat group with member profile IDs. Returns new group ID.
  Future<ChatGroup?> createGroupWithProfiles(
      {required String name,
      String? description,
      required String createdByProfileId,
      required List<String> memberProfileIds,
      GROUP_CHAT_TYPE type = GROUP_CHAT_TYPE.chat}) async {
    String cleanName = name.trim();
    // Ensure creator is included and uniqueness
    final allProfileIds = {
      createdByProfileId,
      ...memberProfileIds,
    }.toList();
    /**
     * If an existing chat has same members, return that instead.
     * This is only triggered when a name is empty, chats without name are
     *   identified by their group members.
     */
    if (cleanName.isEmpty && type == GROUP_CHAT_TYPE.chat) {
      final existing = (await getUserChatGroups(createdByProfileId)).where((g) {
        if (g.members.length != allProfileIds.length) return false;
        for (final m in g.members) {
          if (!allProfileIds.contains(m)) {
            return false;
          }
        }
        return true;
      }).firstOrNull;
      if (existing != null) {
        return existing;
      }
    }
    final cleanDescription =
        (description?.trim().isEmpty ?? true) ? null : description!.trim();

    developer.log(
      'createGroupWithProfiles() name="$cleanName", '
      'createdByProfileId=$createdByProfileId, '
      'memberCount=${allProfileIds.length}',
      name: 'ChatRepository',
    );

    // groups.created_by should be a profile id (auth user id)
    final insertedGroup = await supabase.groups
        .insert(Groups.insert(
          createdById: createdByProfileId,
          name: cleanName,
          description: cleanDescription,
          type: type,
        ))
        .select()
        .single();

    final groupId = Groups.fromJson(insertedGroup).id;

    developer.log(
      'createGroupWithProfiles() inserted groupId=$groupId',
      name: 'ChatRepository',
    );

    final memberRows = allProfileIds.map((profileId) {
      return {
        'group_id': groupId,
        'profile_id': profileId,
      };
    }).toList();

    developer.log(
      'createGroupWithProfiles() inserting member rows: $memberRows',
      name: 'ChatRepository',
    );

    await supabase.from('group_members').insert(memberRows);

    return getGroup(groupId, createdByProfileId);
  }

  Future<String> _getNextGroupName({
    required String baseName,
  }) async {
    final result = await supabase.rpc(
      'get_next_group_name',
      params: {
        'p_base_name': baseName,
      },
    );

    return result as String;
  }

  Future<ChatGroup?> createDirectRequestGroup({
    required String name,
    String? description,
    required String createdByProfileId,
    required String otherProfileId,
    required GROUP_CHAT_TYPE type,
  }) async {
    return createGroupWithProfiles(
      name: await _getNextGroupName(baseName: name),
      description: description,
      createdByProfileId: createdByProfileId,
      memberProfileIds: [otherProfileId],
      type: type,
    );
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

  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    await supabase.groups.update(Groups.update(name: name)).eq(Groups.c_id, groupId);
  }

  Future<void> deleteGroup(String id) async {
    await supabase.from('messages').delete().eq('to_id', id);
    await supabase.from('groups').delete().eq('id', id);
  }

  Future<ChatGroup?> getGroup(String id, String currentUid) async {
    final response = await supabase.groups.select('''
      id,
      name,
      description,
      type,
      group_members(
        profile_id,
        user_profiles(
          people(
            given_name,
            user_profile_id
          )
        )
      )
    ''').eq(Groups.c_id, id).maybeSingle().withConverter(
          (resp) {
            if (resp == null) return null;
            List<Map<String, dynamic>> members = (resp['group_members'] as List)
                .map((e) => (e as Map<String, dynamic>)['user_profiles']
                    ['people'] as Map<String, dynamic>)
                .toList();
            return (
              group: Groups.fromJson(resp),
              members: People.converter(members),
            );
          },
        );
    if (response == null) return null;
    return responseToChatGroup(response, currentUid);
  }
}
