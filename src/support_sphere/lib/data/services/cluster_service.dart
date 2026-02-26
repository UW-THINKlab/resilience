import 'package:geodesy/geodesy.dart';
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
    return await _supabaseClient.from('clusters').select('*').eq('id', clusterId).maybeSingle();
  }

  Future<PostgrestList?> getAllClusters() async {
    return await _supabaseClient.from('clusters').select('*');
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

  Future<PostgrestMap?> updateClusterMeetingPoint(String clusterId, LatLng location) async {
    // update
    await _supabaseClient.from('clusters').update({'meeting_point': location}).eq('id', clusterId);
    // new version
    return getClusterById(clusterId);
  }

  Future<PostgrestList?> getCaptainsByClusterId(String clusterId) async {
    return await _supabaseClient
        .from('user_captain_clusters')
        .select('''
        captain:user_roles (
          user_profile:user_profiles (
            id,
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

  /// Retrieves all users in a cluster with their captain status.
  /// Returns a list of people with their user_profile_id and captain status.
  Future<PostgrestList?> getUsersByClusterId(String clusterId) async {
    return await _supabaseClient.from('households').select('''
      people_groups (
        people (
          id,
          user_profile_id,
          given_name,
          family_name,
          nickname,
          is_safe,
          needs_help
        )
      )
    ''').eq('cluster_id', clusterId);
  }

  /// Grants the cluster captain role to the user with the given [userProfileId]
  /// for the cluster with the given [clusterId].
  Future<void> grantClusterCaptain({
    required String userProfileId,
    required String clusterId,
  }) async {
    // Upsert the user role to SUBCOM_AGENT
    await _supabaseClient.from('user_roles').upsert(
      {
        'user_profile_id': userProfileId,
        'role': AppRoles.subcommunityAgent,
      },
      onConflict: 'user_profile_id',
    );

    // Retrieve the user_role id
    final userRoleData = await _supabaseClient
        .from('user_roles')
        .select('id')
        .eq('user_profile_id', userProfileId)
        .single();

    final String userRoleId = userRoleData['id'];

    // Insert into user_captain_clusters if not already present
    await _supabaseClient.from('user_captain_clusters').upsert(
      {
        'cluster_id': clusterId,
        'user_role_id': userRoleId,
      },
      onConflict: 'cluster_id, user_role_id',
    );
  }

  /// Revokes the cluster captain role from the user with the given [userProfileId]
  /// for the cluster with the given [clusterId].
  Future<void> revokeClusterCaptain({
    required String userProfileId,
    required String clusterId,
  }) async {
    // Retrieve the user_role id
    final userRoleData = await _supabaseClient
        .from('user_roles')
        .select('id')
        .eq('user_profile_id', userProfileId)
        .maybeSingle();

    if (userRoleData == null) return;

    final String userRoleId = userRoleData['id'];

    // Delete the captain cluster entry
    await _supabaseClient
        .from('user_captain_clusters')
        .delete()
        .eq('cluster_id', clusterId)
        .eq('user_role_id', userRoleId);

    // Check if the user has remaining captaincies
    final remaining = await _supabaseClient
        .from('user_captain_clusters')
        .select('id')
        .eq('user_role_id', userRoleId);

    if (remaining.isEmpty) {
      // Revert the user role to USER
      await _supabaseClient
          .from('user_roles')
          .update({'role': AppRoles.user})
          .eq('user_profile_id', userProfileId);
    }
  }
}