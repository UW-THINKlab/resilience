import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart';

class UserService {
  final SupabaseClient _supabaseClient = supabase;

  /// Retrieves the user profile and person by user id.
  /// Returns a [PostgrestMap] object if the user profile and person exist.
  /// Returns null if the user profile and person do not exist.
  Future<PostgrestMap?> getProfileAndPersonByUserId(String userId) async {
    /// This query will perform a join on the user_profiles and people tables
    return await _supabaseClient.from('user_profiles').select('''
      id,
      username,
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
    required String userName,
  }) async {
    await _supabaseClient.from('user_profiles').insert({
      'id': userId,
      'username': userName,
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
}