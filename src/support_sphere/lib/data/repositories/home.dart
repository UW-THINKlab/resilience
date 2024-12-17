import 'package:geodesy/geodesy.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/services/cluster_service.dart';

class HomeRepository {
  final ClusterService _clusterService = ClusterService();

  // get all required data for displaying map on home page
  Future<
      ({
        List<CaptainMarker>? captainMarkers,
        Cluster? cluster,
      })?> getHomeData(String userProfileId) async {
    final clusterData =
        await _clusterService.getClusterIdByUserProfileId(userProfileId);
    final clusterId =
        clusterData?['people']['people_groups']['households']['cluster_id'];

    if (clusterId == null) return null;

    final userCluster = await _clusterService.getClusterById(clusterId);
    final captainsData =
        await _clusterService.getCaptainsByClusterId(clusterId);
    final captains =
        captainsData?.map((row) => row['captain']['user_profile']['person']);

    return (
      captainMarkers: captains
          ?.map((captain) => CaptainMarker(
                id: captain['id'],
                familyName: captain['family_name'],
                givenName: captain['given_name'],
                householdGeom: captain['people_groups']['households']['geom'] != null
                    ? PolygonCentroid.findPolygonCentroid(
                        captain['people_groups']['households']['geom']['coordinates'][0]
                            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                            .toList())
                    : null,
              ))
          .toList(),
      cluster: userCluster != null ? Cluster.fromJson(userCluster) : null,
    );
  }
}
