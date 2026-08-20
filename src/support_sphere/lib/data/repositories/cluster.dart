import 'package:geodesy/geodesy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/generated_classes.dart'
    show ClusterCaptainsView, UserRoles, APP_ROLES;
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/services/cluster_service.dart';

final log = Logger('ClusterRepository');


class ClusterRepository {
  final ClusterService _clusterService = ClusterService();

  // get all required data for displaying map on home page
  Future<Cluster?> getClusterByUser(String userProfileId) async {

    log.fine("Getting cluster for user id: $userProfileId");

    final clusterData = await _clusterService.getClusterIdByUserProfileId(userProfileId);
    final clusterId =  clusterData?['people']['people_groups']['households']['cluster_id'];
    if (clusterId == null) return null;

    final userCluster = await _clusterService.getClusterById(clusterId);
    final cluster = userCluster != null ? Cluster.fromJson(userCluster) : null;
    return cluster;
  }

  Future<Cluster?> getCluster(String clusterId) async {
    final cluster = await _clusterService.getClusterById(clusterId);
    return cluster != null ? Cluster.fromJson(cluster) : null;
  }

  Future<List<Cluster>> getAllClusters() async {
    final clusterList = await _clusterService.getAllClusters();
    if (clusterList == null || clusterList.isEmpty) {
      return [];
    }

    final List<Cluster> clusters = [];
    for (var clusterData in clusterList) {
      var cluster = Cluster.fromJson(clusterData);
      clusters.add(cluster);
    }
    log.fine("getAllClusters found ${clusters.length} clusters");

    return clusters;
  }

  Future<Cluster> updateClusterMeetingPoint(Cluster cluster, LatLng? meetingPoint, String? description) async {
    if (meetingPoint == null) {
      return cluster;
    }
    // update db
    final data = await _clusterService.updateClusterMeetingPoint(cluster.id, meetingPoint, description);
    //log.fine("<<< data: $data");
    final updated = Cluster.fromJson(data!);
    //log.fine("<<< Updated cluster meeting point: ${updated.meetingPoint}");
    return updated;
  }

  Future<List<Household>> getHouseholds(String clusterId) {
    return _clusterService.getHouseholds(clusterId);
  }

  Future<void> addHousehold(String clusterId, Household household) async {
    return _clusterService.addHousehold(clusterId, household);
  }

  Future<void> deleteHousehold(String householdId) async {
    return _clusterService.deleteHousehold(householdId);
  }

  /// upsetCluster - takes a name to value mapping to apply values to a cluster
  /// assumes 'id' is set.
  /// 'captains' is a special case, that must be managed a different way.
  Future<void> upsertCluster(Map<String, dynamic> clusterUpdate) async {
    final clusterId = clusterUpdate['id'];
    // checking captains
    if (clusterUpdate.containsKey('captains')) {
      final captains = clusterUpdate.remove('captains');
      await updateCaptains(clusterId, captains);
    }
    // TODO any geometry will also need special case

    await _clusterService.upsertCluster(clusterUpdate);
  }

  Future<void> deleteCluster(String clusterId) async {
    return _clusterService.deleteCluster(clusterId);
  }

  Future<List<ClusterCaptainsView>> getCaptainsViewByClusterId(
      String clusterId) async {
    final data = await _clusterService.getCaptainsViewByClusterId(clusterId);
    if (data == null) return [];
    return ClusterCaptainsView.converter(data);
  }

  Future<void> updateCaptains(String clusterId, List<Person> captains) async {
    final newIds = captains
        .map((c) => c.profile?.id)
        .whereType<String>()
        .toSet();

    final currentRows = await getCaptainsViewByClusterId(clusterId);
    final currentIds = currentRows
        .map((r) => r.userProfileId)
        .whereType<String>()
        .toSet();

    for (final id in newIds.difference(currentIds)) {
      await _addClusterCaptain(clusterId, id);
    }
    for (final id in currentIds.difference(newIds)) {
      await _removeClusterCaptain(clusterId, id);
    }
  }

  Future<void> _addClusterCaptain(
      String clusterId, String userProfileId) async {
    final roleRow = await _clusterService.upsertUserRole(
        userProfileId, APP_ROLES.subcom_agent);
    await _clusterService.insertUserCaptainCluster(
        clusterId, roleRow['id'] as String);
  }

  Future<void> _removeClusterCaptain(
      String clusterId, String userProfileId) async {
    final roleRow = await _clusterService.getUserRoleByProfileId(
        userProfileId, APP_ROLES.subcom_agent);
    if (roleRow == null) return;
    final userRoleId = roleRow['id'] as String;

    await _clusterService.deleteUserCaptainCluster(clusterId, userRoleId);

    final remaining =
        await _clusterService.getUserCaptainClustersByRoleId(userRoleId);
    if (remaining.isEmpty) {
      await _clusterService.deleteUserRole(userRoleId);
    }
  }

  Future<List<String>> getCommunityAdminProfileIds() async {
    final data = await _clusterService.getCommunityAdmins();
    if (data == null) return [];
    return data
        .map((row) => row[UserRoles.c_userProfileId] as String?)
        .whereType<String>()
        .toList();
  }

  Future<void> updateCommunityAdmins(List<Person> admins) async {
    final newIds =
        admins.map((a) => a.profile?.id).whereType<String>().toSet();
    final currentIds = (await getCommunityAdminProfileIds()).toSet();

    for (final id in newIds.difference(currentIds)) {
      await _clusterService.upsertUserRole(id, APP_ROLES.com_admin);
    }
    for (final id in currentIds.difference(newIds)) {
      final roleRow =
          await _clusterService.getUserRoleByProfileId(id, APP_ROLES.com_admin);
      if (roleRow != null) {
        await _clusterService.deleteUserRole(roleRow[UserRoles.c_id] as String);
      }
    }
  }

  Future<int> getHouseholdCount() async {
    return _clusterService.getHouseholdCount();
  }

  Future<Set<String>> getClusterIdsWithCaptains() async {
    final rows = await _clusterService.getAllClusterCaptains();
    return (rows ?? [])
        .map((row) => row['cluster_id'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<Captains?> getCaptainsByClusterId(String clusterId) async {
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
}