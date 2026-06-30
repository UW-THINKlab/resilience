import 'dart:async';

import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/services/user_service.dart';
import 'package:support_sphere/data/services/auth_service.dart';

final log = Logger('UserRepository');

/// Repository for user interactions.
/// This class is responsible for handling user-related data operations.
class UserRepository {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ClusterRepository _clusters = ClusterRepository();

  // Builds a mapping of all members: profile-id -> Person
  // Can be used for cached lookup of user profile info
  // NOTE: There should probably be a "person view" with all
  // salient details. This dumps a cache of all users into a users web cache
  Future<Map<String, Person>> getAllMembers() async {
    final data = await _userService.getAllPeople();

    Map<String, Person> members = {};

    if (data != null) {
      for (var member in data) {
        final person = Person.fromJson(member);
        if (person.profile != null) {
          members[person.profile!.id] = person;
        }
      }
    }
    return members;
  }

  /// Get the household members by household id.
  /// Returns a [HouseHoldMembers] object if the household members exist.
  /// Returns null if the household members do not exist.
  /// The [HouseHoldMembers] object contains a list of [Person] objects.
  Future<HouseHoldMembers?> getHouseholdMembersByHouseholdId(
      String householdId) async {
    final data =
        await _userService.getHouseholdMembersByHouseholdId(householdId);
    if (data != null) {
      List<Person> members = [];
      for (var member in data) {
        members.add(Person.fromJson(member["people"]));
      }

      return HouseHoldMembers(members: members);
    }
    return null;
  }

  Future<List<Person>> getClusterMembers(String clusterId) async {
    List<Person> people = [];
    final data = await _userService.getClusterMembers(clusterId);
    for (var item in data) {
      people.add(Person.fromJson(item["people"]));
    }
    return people;
  }

  /// Get the household by person id.
  Future<Household?> getHouseholdByPersonId(String personId) async {
    log.fine("getting household for person id: $personId");
    final data = await _userService.getPersonHouseholdByPersonId(personId);
    if (data != null) {
      return Household.fromJson(data["households"]);
    }
    return null;
  }

  /// Get the user profile and person by user id retrieved from [MyAuthUser].
  /// Returns a [Person] object if the user profile and person exist.
  Future<Person?> getPersonProfileByUserId({
    required String userId,
  }) async {
    final data = await _userService.getProfileAndPersonByUserId(userId);
    if (data != null) {
      return Person.fromJson(data["people"]);
    }
    return null;
  }

  Stream<Person?> personForId({required String userId}) async* {
    yield await getPersonProfileByUserId(userId: userId);
  }

  Future<Captains?> getCaptainsByClusterId(String clusterId) async {
    return _clusters.getCaptainsByClusterId(clusterId);
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
    required Map<String, dynamic> data,
  }) async {
    String userId = user.id;
    // Create a user profile with the given user id
    await _userService.createUserProfile(
      userId: userId,
    );

    // Create a person with the given user id, given name, family name, and household id
    await _userService.createPerson(
        userId: userId,
        givenName: givenName,
        familyName: familyName,
        householdId: data["household_id"]);

    // Invalidate the signup code used to create the user
    //await _authService.invalidateSignupCode(data["code"]);
    String email = user.email ?? '[unknown]';
    await _authService.logUseOfSignupCode(
        email, data["household_id"], data["code"]);
  }

  Future<void> updateUserName({
    required String personId,
    String? givenName,
    String? familyName,
  }) async {
    await _userService.updatePerson(
      id: personId,
      givenName: givenName,
      familyName: familyName,
    );
  }

  Future<void> updateHousehold({
    required String householdId,
    String? address,
    String? pets,
    String? accessibilityNeeds,
    String? notes,
  }) async {
    await _userService.updateHousehold(
      id: householdId,
      address: address,
      pets: pets,
      accessibilityNeeds: accessibilityNeeds,
      notes: notes,
    );
  }

  Future<Person?> getMyProfile() async {
    return await getPersonProfileByUserId(
        userId: _authService.getSignedInUser()!.id);
  }

  Future<Household?> getMyHousehold() async {
    log.finer("calling: getMyProfile");
    final profile = await getMyProfile();
    if (profile != null) {
      log.finer("Found profile: $profile");
      return await getHouseholdByPersonId(profile.id);
    } else {
      log.fine("NO PROFILE");
      return null;
    }
  }

  Future<String?> getMyClusterId() async {
    final household = await getMyHousehold();
    log.finer("✅ GOT household: $household");

    if (household != null) {
      return household.clusterId;
    } else {
      log.warning("My household not found");
      return null;
    }
  }

  Future<Cluster?> getMyCluster() async {
    final myClusterId = await getMyClusterId();
    log.finer("✅ GOT clusterid: $myClusterId");
    if (myClusterId != null) {
      return await _clusters.getCluster(myClusterId);
    } else {
      return null;
    }
  }

  Future<void> blockUser({
    required String blockerId,
    required String blockeeId,
  }) async {
    await _userService.blockPerson(
      blockerId: blockerId,
      blockeeId: blockeeId,
    );
  }

  Future<void> unblockUser({
    required String blockerId,
    required String blockeeId,
  }) async {
    await _userService.unblockPerson(
      blockerId: blockerId,
      blockeeId: blockeeId,
    );
  }

  Future<bool> isUserBlocking({
    required String blockerId,
    required String blockeeId,
  }) async {
    return await _userService.isUser1BlockingUser2(
      user1Id: blockerId,
      user2Id: blockeeId,
    );
  }

  Future<bool> isEitherUserBlocked({
    required String user1Id,
    required String user2Id,
  }) async {
    return await _userService.isUser1BlockingUser2(
          user1Id: user1Id,
          user2Id: user2Id,
        ) ||
        await _userService.isUser1BlockingUser2(
          user1Id: user2Id,
          user2Id: user1Id,
        );
  }
}
