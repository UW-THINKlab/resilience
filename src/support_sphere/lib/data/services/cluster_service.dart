import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ClusterService {
  final SupabaseClient _supabaseClient = supabase;

  /// Retrieves the cluster by cluster id.
  /// Returns a [Cluster] object if the cluster exist.
  /// Returns null if the cluster does not exist.
  Future<PostgrestMap?> getClusterById(String clusterId) async {
    /// This query will perform a join on the user_profiles and people tables
    return await _supabaseClient.from('clusters').select('''
      id,
      name,
      meeting_place
    ''').eq('id', clusterId).maybeSingle();
  }

  Future<PostgrestMap?> getClusterIdByUserProfileId(String userProfileId) async {
    return await _supabaseClient.from('user_profiles').select('''
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

  Future<PostgrestList?> getCaptainsByClusterId(String clusterId) async {
    return await _supabaseClient
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
