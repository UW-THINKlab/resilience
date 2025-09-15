import 'package:geodesy/geodesy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/repositories/cluster.dart' show ClusterRepository;
import 'package:support_sphere/data/services/cluster_service.dart';
import 'package:support_sphere/data/services/poi_service.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';

final log = Logger('HomeRepository');


class HomeRepository {
  final ClusterService _clusterService = ClusterService();
  final ClusterRepository clusterRepo = ClusterRepository();
  final PointOfInterestService _poiService = PointOfInterestService();

  // get all required data for displaying map on home page
  Future<
      ({
        List<CaptainMarker>? captainMarkers,
        Cluster? cluster,
        List<PointOfInterest>? pointsOfInterest,
      })?> getHomeData(String userProfileId) async {
    final clusterData =
        await _clusterService.getClusterIdByUserProfileId(userProfileId);
    final clusterId =
        clusterData?['people']['people_groups']['households']['cluster_id'];

    if (clusterId == null) return null;

    final cluster = await clusterRepo.getCluster(clusterId);

    final captainsData =
        await _clusterService.getCaptainsByClusterId(clusterId);
    final captains =
        captainsData?.map((row) => row['captain']['user_profile']['person']);

    final pointsOfInterest = await _poiService.getPointsOfInterest();

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
      cluster: cluster,
      pointsOfInterest: pointsOfInterest,
    );
  }
}
