import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/services/user_service.dart';

/// Repository for user interactions.
/// This class is responsible for handling user-related data operations.
class UserRepository {
  final UserService _userService = UserService();

  /// Get the user profile and person by user id retrieved from [AuthUser].
  /// Returns a [Person] object if the user profile and person exist.
  Future<Person?> getPersonProfileByUserId({
    required String userId,
  }) async {
    final data = await _userService.getProfileAndPersonByUserId(userId);

    if (data != null) {
      Map<String, dynamic> personData = data["people"];

      return Person(
        id: personData["id"],
        profile: Profile(id: userId, userName: data["username"]),
        givenName: personData["given_name"],
        familyName: personData["family_name"],
        nickname: personData["nickname"],
        isSafe: personData["is_safe"],
        needsHelp: personData["needs_help"],
      );
    }
    return null;
  }


  /// Create a new user with the given user info.
  /// This will perform two operations:
  /// 1. Create a user profile with the given user id and username.
  /// 2. Create a person with the given user id, given name, and family name.
  /// Returns a [Future] that completes when the user is created.
  Future<void> createNewUser({
    required supabase_flutter.User user,
    required String userName,
    required String givenName,
    required String familyName,
  }) async {
    String userId = user.id;
    await _userService.createUserProfile(
      userId: userId,
      userName: userName,
    );
    await _userService.createPerson(
        userId: userId, givenName: givenName, familyName: familyName);
  }
}
