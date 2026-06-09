import 'package:geodesy/geodesy.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/repositories/cluster.dart'
    show ClusterRepository;
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
      captainMarkers: captains?.map((captain) {
        LatLng? householdGeom;
        final geom = captain['people_groups']['households']['geom'];
        switch (geom['type']) {
          case "Point":
            final latlng =
                LatLng(geom['coordinates'][1], geom['coordinates'][0]);
            householdGeom = PolygonCentroid.findPolygonCentroid([latlng]);
            break;
          default:
            log.warning(
              'Geom type of type ${geom['type'].runtimeType} is not handled',
            );
        }
        return CaptainMarker(
          id: captain['id'],
          familyName: captain['family_name'],
          givenName: captain['given_name'],
          householdGeom: householdGeom,
        );
      }).toList(),
      cluster: cluster,
      pointsOfInterest: pointsOfInterest,
    );
  }
}
