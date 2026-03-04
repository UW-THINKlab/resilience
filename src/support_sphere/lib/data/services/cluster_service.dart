import 'package:geodesy/geodesy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart' show Household;
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:uuid/v4.dart' show UuidV4;

final log = Logger('ClusterService');

class ClusterService {
  /// Retrieves the cluster by cluster id.
  /// Returns a [Cluster] object if the cluster exist.
  /// Returns null if the cluster does not exist.
  Future<PostgrestMap?> getClusterById(String clusterId) async {
    /// This query will perform a join on the user_profiles and people tables
    return await supabase.from('clusters').select('*').eq('id', clusterId).maybeSingle();
  }

  Future<PostgrestList?> getAllClusters() async {
    return await supabase.from('clusters').select('*');
  }

  Future<PostgrestMap?> getClusterIdByUserProfileId(String userProfileId) async {
    return await supabase.from('user_profiles').select('''
      id,
      people (
        people_groups (
          households (
            cluster_id
          )
        )
      )
    ''').eq('id', userProfileId).maybeSingle();
  }

  // FIXME - couldn't find an existing lib
  String pointGisStr(LatLng location) {
    return "POINT(${location.longitude} ${location.latitude})";
  }

  Future<PostgrestMap?> updateClusterMeetingPoint(String clusterId, LatLng location, String? description) async {
    // update
    log.fine("updateClusterMeetingPoint: $clusterId $location");
    await supabase.from('clusters').update({
      'meeting_point': pointGisStr(location),
      'meeting_place': description,
    }).eq('id', clusterId);

    // new version
    final updatedCluster = await getClusterById(clusterId);
    final point = updatedCluster?["meeting_point"];
    log.fine(">>> updated meeting point: $point");
    return updatedCluster;
  }

  Future<PostgrestList?> getCaptainsByClusterId(String clusterId) async {
    return await supabase
        .from('user_captain_clusters')
        .select('''
        captain:user_roles (
          user_profile:user_profiles (
            person:people (
              id,
              given_name,
              family_name,
              people_groups (
                households (
                  geom
                )
              )
            )
          )
        )
      ''')
        .eq('cluster_id', clusterId)
        .eq('user_roles.role', AppRoles.subcommunityAgent);
  }

  Future<List<Household>> getHouseholds(String clusterId) async {
    PostgrestList? data = await supabase.from('households').select('*').eq('cluster_id', clusterId);

    List<Household> households = [];

    for (var record in data) {
      households.add(Household.fromJson(record));
    }

    return households;
  }

  Future<void> addHousehold(String clusterId, Household household) async {
    await supabase.from('households').insert({
      'id': const UuidV4().generate(),
      'cluster_id': household.clusterId,
      'name': household.name,
      'address': household.address,
      'notes': household.notes,
      'pets': household.pets,
      'accessibility_needs': household.accessibilityNeeds,
      //'created_by': supabase.auth.currentUser!.id,
      //'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteHousehold(String householdId) async {
    await supabase.from('households').delete().eq('id', householdId);
  }

  Future<void> addCluster(Cluster cluster) async {
    // FIXME Cluster -> json
    await supabase.from('clusters').insert({
      'id': cluster.id,
      'name': cluster.name,
      'notes': cluster.notes,
      'meeting_place': cluster.meetingPlace,
      'geom': cluster.geom,
      'meeting_point': cluster.meetingPoint,
      'captains': cluster.captains,
    });
  }

  Future<void> deleteCluster(String clusterId) async {
    await supabase.from('clusters').delete().eq('id', clusterId);
  }
}
