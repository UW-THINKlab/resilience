import 'dart:async';

import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/services/cluster_service.dart';
import 'package:support_sphere/data/services/user_service.dart';
import 'package:support_sphere/data/services/auth_service.dart';

final log = Logger('UserRepository');


/// Repository for user interactions.
/// This class is responsible for handling user-related data operations.
class UserRepository {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ClusterService _clusterService = ClusterService();
  final ClusterRepository _clusters = ClusterRepository();

  Future<Map<String,Person>> getAllMembers() async {
    final data = await _userService.getAllPeople();

    log.fine("people data: $data");

    Map<String,Person> members = {};

    if (data != null) {
      for (var member in data) {
        //log.fine(">>> $member");
        //Map<String, dynamic> personData = member["people"];
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


  Future<(Cluster?,List<Person?>)> getClusterWithPeople(String clusterId) async {
    final cluster = await _clusters.getCluster(clusterId);

    List<Person> people = [];
    final data = await _userService.getPeopleByCluster(clusterId);
    if (data != null) {

      for (var member in data) {
        Map<String, dynamic> personData = member["people"];
        Profile? profile;
        String? userProfileId = personData["user_profile_id"];

        if (userProfileId != null) {
          profile = Profile(id: userProfileId);
        }

        people.add(Person(
          id: personData["id"],
          profile: profile,
          givenName: personData["given_name"],
          familyName: personData["family_name"],
          nickname: personData["nickname"],
          isSafe: personData["is_safe"],
          needsHelp: personData["needs_help"],
        ));
      }
    }
    return (cluster,people);
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
        cluster_id: householdData["cluster_id"],
      );
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

  Stream<Person?> personForId({required String userId}) async* {
    yield await getPersonProfileByUserId(userId: userId);
  }

  /// Get the cluster by cluster id retrieved from [Household].
  /// Returns a [Cluster] object
  Future<Cluster?> getClusterById({
    required String clusterId,
  }) async {
    final data = await _clusterService.getClusterById(clusterId);

    if (data != null) {
      return Cluster(
        id: data["id"],
        name: data["name"],
        meetingPlace: data["meeting_place"],
      );
    }
    return null;
  }

  Future<Captains?> getCaptainsByClusterId({
    required String clusterId,
  }) async {
    final data = await _clusterService.getCaptainsByClusterId(clusterId);

    if (data != null) {
      List<Person> captains = [];

      for (var record in data) {
        Map<String, dynamic> captainData = record["captain"]["user_profile"]["person"];

        captains.add(Person(
          id: captainData["id"],
          givenName: captainData["given_name"],
          familyName: captainData["family_name"],
        ));
      }

      return Captains(people: captains);
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
    required Map<String, dynamic> data,
  }) async {
    String userId = user.id;
    // Create a user profile with the given user id
    await _userService.createUserProfile(
      userId: userId,
    );

    // Create a person with the given user id, given name, family name, and household id
    await _userService.createPerson(
        userId: userId, givenName: givenName, familyName: familyName, householdId: data["household_id"]);

    // Invalidate the signup code used to create the user
    await _authService.invalidateSignupCode(data["code"]);
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
}
