import 'dart:async';

import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart';

final log = Logger('UserService');

class UserService {
  /// Retrieves every person in the system
  Future<PostgrestList?> getAllPeople() async {
    return await supabase.from('people').select('*');
  }

  /// Retrieves the person household by person id.
  Future<PostgrestMap?> getPersonHouseholdByPersonId(String personId) async {
    log.fine("getting household for person id=$personId");
    return await supabase.from('people_groups').select('''
      people(
        id
      ),
      households(
        id,
        name,
        address,
        notes,
        pets,
        accessibility_needs,
        cluster_id
      )
    ''').eq('people_id', personId).maybeSingle();
  }

  /// Retrieves the household members by household id.
  Future<PostgrestList?> getHouseholdMembersByHouseholdId(
      String householdId) async {
    log.fine("getting household members for household id=$householdId");
    return await supabase.from('people_groups').select('''
      people(
        id,
        user_profile_id,
        given_name,
        family_name,
        nickname,
        is_safe,
        needs_help
      )
    ''').eq('household_id', householdId);
  }

  Future<PostgrestList> getClusterMembers(String clusterId) async {
    return await supabase.from('people_groups').select('''
      people(id, user_profile_id, given_name, family_name, nickname, is_safe, needs_help),
      households (
        cluster_id
      )
    ''').eq('households.cluster_id', clusterId);
  }

  /// Retrieves the user profile and person by user id.
  /// Returns a [PostgrestMap] object if the user profile and person exist.
  /// Returns null if the user profile and person do not exist.
  Future<PostgrestMap?> getProfileAndPersonByUserId(String userId) async {
    log.finer("getting profile for user id=$userId");

    /// This query will perform a join on the user_profiles and people tables
    return await supabase.from('user_profiles').select('''
      id,
      people(
        id,
        user_profile_id,
        given_name,
        family_name,
        nickname,
        is_safe,
        needs_help
      )
    ''').eq('id', userId).maybeSingle();
  }

  /// Creates a user profile with the given user id and username.
  Future<void> createUserProfile({
    required String userId,
  }) async {
    await supabase.from('user_profiles').insert({
      'id': userId,
    });
  }

  /// Creates a person with the given user id, given name, and family name.
  Future<void> createPerson({
    required String userId,
    required String givenName,
    required String familyName,
    required String householdId,
  }) async {
    final personId = const UuidV4().generate();
    await supabase.from('people').insert({
      'id': personId,
      'user_profile_id': userId,
      'given_name': givenName,
      'family_name': familyName,
      'nickname': '',
      'is_safe': true,
      'needs_help': false,
    });
    await linkPersonToHousehold(personId: personId, householdId: householdId);
  }

  /// Updates a person's details in the people table.
  Future<void> updatePerson({
    required String id,
    String? givenName,
    String? familyName,
    String? nickname,
    bool? isSafe,
    bool? needsHelp,
  }) async {
    final payload = <String, dynamic>{};

    if (givenName != null) payload['given_name'] = givenName;
    if (familyName != null) payload['family_name'] = familyName;
    if (nickname != null) payload['nickname'] = nickname;
    if (isSafe != null) payload['is_safe'] = isSafe;
    if (needsHelp != null) payload['needs_help'] = needsHelp;

    await supabase.from('people').update(payload).eq('id', id);
  }

  /// Updates a household's details in the households table.
  Future<void> updateHousehold({
    required String id,
    String? address,
    String? pets,
    String? accessibilityNeeds,
    String? notes,
  }) async {
    final payload = <String, dynamic>{};

    if (address != null) payload['address'] = address;
    if (pets != null) payload['pets'] = pets;
    if (accessibilityNeeds != null) {
      payload['accessibility_needs'] = accessibilityNeeds;
    }
    if (notes != null) payload['notes'] = notes;

    await supabase.from('households').update(payload).eq('id', id);
  }

  /// Link a person to a household.
  /// This will create a new row in the people_groups table.
  Future<void> linkPersonToHousehold({
    required String personId,
    required String householdId,
  }) async {
    await supabase.from('people_groups').insert({
      'people_id': personId,
      'household_id': householdId,
    });
  }

  Future<void> blockPerson({
    required String blockerId,
    required String blockeeId,
  }) async {
    await supabase.blocks.insert(Blocks.insert(
      blocker: blockerId,
      blockee: blockeeId,
    ));
  }

  Future<void> unblockPerson({
    required String blockerId,
    required String blockeeId,
  }) async {
    await supabase.blocks
        .delete()
        .eq(Blocks.c_blocker, blockerId)
        .eq(Blocks.c_blockee, blockeeId);
  }

  Future<bool> isUser1BlockingUser2({
    required String user1Id,
    required String user2Id,
  }) async {
    final blocks = await supabase.blocks
        .select()
        .eq(Blocks.c_blocker, user1Id)
        .eq(Blocks.c_blockee, user2Id)
        .withConverter(Blocks.converter);
    return blocks.isNotEmpty;
  }

  Stream<List<People>> blockedUsersStream(String userId) {
    return supabase.blocks
        .stream(primaryKey: [Blocks.c_blocker, Blocks.c_blockee])
        .eq(Blocks.c_blocker, userId)
        .order(Blocks.c_createdAt)
        .map(Blocks.converter)
        .asyncMap((List<Blocks> blocks) async {
          List<People> res = [];
          for (Blocks b in blocks) {
            res.add(await personByProfileId(b.blockee));
          }
          return res;
        });
  }

  Future<People> personByProfileId(String profileId) {
    return supabase.people
        .select()
        .eq(People.c_userProfileId, profileId)
        .single()
        .withConverter(People.converterSingle);
  }
}
