import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart';

class UserService {
  final SupabaseClient _supabaseClient = supabase;

  /// Retrieves the person household by person id.
  Future<PostgrestMap?> getPersonHouseholdByPersonId(String personId) async {
    return await _supabaseClient.from('people_groups').select('''
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
  Future<PostgrestList?> getHouseholdMembersByHouseholdId(String householdId) async {
    return await _supabaseClient.from('people_groups').select('''
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

  /// Retrieves the user profile and person by user id.
  /// Returns a [PostgrestMap] object if the user profile and person exist.
  /// Returns null if the user profile and person do not exist.
  Future<PostgrestMap?> getProfileAndPersonByUserId(String userId) async {
    /// This query will perform a join on the user_profiles and people tables
    return await _supabaseClient.from('user_profiles').select('''
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
    await _supabaseClient.from('user_profiles').insert({
      'id': userId,
    });
  }

  /// Creates a person with the given user id, given name, and family name.
  Future<void> createPerson({
    required String userId,
    required String givenName,
    required String familyName,
  }) async {
    await _supabaseClient.from('people').insert({
      'id': const UuidV4().generate(),
      'user_profile_id': userId,
      'given_name': givenName,
      'family_name': familyName,
      'nickname': '',
      'is_safe': true,
      'needs_help': false,
    });
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

    await _supabaseClient
        .from('people')
        .update(payload)
        .eq('id', id);
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
    if (accessibilityNeeds != null) payload['accessibility_needs'] = accessibilityNeeds;
    if (notes != null) payload['notes'] = notes;

    await _supabaseClient
        .from('households')
        .update(payload)
        .eq('id', id);
  }
}