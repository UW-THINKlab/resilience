import 'package:geodesy/geodesy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/clusters.dart';
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
      updateCaptains(clusterId, captains);
    }
    // TODO any geometry will also need special case

    _clusterService.upsertCluster(clusterUpdate);
  }

  Future<void> deleteCluster(String clusterId) async {
    return _clusterService.deleteCluster(clusterId);
  }

  Future<void> addClusterCaptain(String clusterId, Person? person) async {
    log.fine("IMPLEMENT adding ${person?.name()} as captain for cluster id: $clusterId");

    // FIXME
    // check if they're already a captain: role
    // add the new captain role in user_role, get id
    // use that ID=user_role_id to add new user_cluser_captain, with cluster_id and new UUID
  }

  Future<void> removeClusterCaptain(String clusterId, Person? person) async {
    log.fine("IMPLEMENT removing ${person?.name()} as captain of cluster id: $clusterId");

    // check if they're already a captain: role
    // add the new captain role in user_role, get id
    // use that ID=user_role_id to add new user_cluser_captain, with cluster_id and new UUID
    // FIXME -
    // delete user_role, or just user_captain_clusters row?
    // BOTH!!!!
    // HOW????
    // supabase.from('user_captain_clusters')
    //   .delete()
    //   .eq('user_role_id', 'id:user_role(user_profile_id=${person?.profile?.id})') // FIXME SYNTAX?
    //   .eq('cluster_id', clusterId);
  }

  Future<void> updateCaptains(String clusterId, List<Person> captains) async {
    // index by id, for easy find
    final newCaptains = { for (var c in captains) c.id: c };

    // get existing captains, and iterate
    final currentCaptains = await getCaptainsByClusterId(clusterId);
    if (currentCaptains != null) {
      for (var captain in currentCaptains.people) {
        // - if in new list - remove from new list, continue
        if (newCaptains.containsKey(captain?.id)) {
          newCaptains.remove(captain?.id);
          // newCaptains contains only new captains, not existing
        }
        // - if not - remove existing captain
        else {
          removeClusterCaptain(clusterId, captain);
        }
      }
    }

    for (var captain in newCaptains.values) {
      addClusterCaptain(clusterId, captain);
    }
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