import 'package:geodesy/geodesy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/constants/string_catalog.dart';

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
    return "POINT(${location.latitude} ${location.longitude})";
  }

  Future<PostgrestMap?> updateClusterMeetingPoint(String clusterId, LatLng location, String? description) async {
    // update
    log.fine("updateClusterMeetingPoint: $clusterId $location");
    await supabase.from('clusters').update({
      'meeting_point': pointGisStr(location),
      'meeting_place': description,
    }).eq('id', clusterId);

    // new version
    return getClusterById(clusterId);
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
}
