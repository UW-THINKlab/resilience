import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/services/user_service.dart';

/// Repository for user interactions.
/// This class is responsible for handling user-related data operations.
class UserRepository {
  final UserService _userService = UserService();

  /// Get the household members by household id.
  /// Returns a [HouseHoldMembers] object if the household members exist.
  /// Returns null if the household members do not exist.
  /// The [HouseHoldMembers] object contains a list of [Person] objects.
  Future<HouseHoldMembers?> getHouseholdMembersByHouseholdId(
      String householdId) async {
    final data = await _userService.getHouseholdMembersByHouseholdId(householdId);

    if (data != null) {
      List<Person> members = [];
      for (var member in data) {
        Map<String, dynamic> personData = member["people"];
        Profile? profile;
        String? userProfileId = personData["user_profile_id"];

        if (userProfileId != null) {
          profile = Profile(id: userProfileId);
        }

        members.add(Person(
          id: personData["id"],
          profile: profile,
          givenName: personData["given_name"],
          familyName: personData["family_name"],
          nickname: personData["nickname"],
          isSafe: personData["is_safe"],
          needsHelp: personData["needs_help"],
        ));
      }

      return HouseHoldMembers(members: members);
    }
    return null;
  }

  /// Get the household by person id.
  Future<Household?> getHouseholdByPersonId(String personId) async {
    final data = await _userService.getPersonHouseholdByPersonId(personId);

    if (data != null) {
      Map<String, dynamic> householdData = data["households"];

      return Household(
        id: householdData["id"],
        name: householdData["name"],
        address: householdData["address"],
        notes: householdData["notes"],
        pets: householdData["pets"],
        accessibility_needs: householdData["accessibility_needs"],
      );
    }
    return null;
  }

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
        profile: Profile(id: userId),
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
  /// 1. Create a user profile with the given user id and empty username
  /// 2. Create a person with the given user id, given name, and family name.
  /// Returns a [Future] that completes when the user is created.
  Future<void> createNewUser({
    required supabase_flutter.User user,
    required String givenName,
    required String familyName,
  }) async {
    String userId = user.id;
    await _userService.createUserProfile(
      userId: userId,
    );
    await _userService.createPerson(
        userId: userId, givenName: givenName, familyName: familyName);
  }
}
