import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart' show Color;
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
        Map<String, (FaIconData, Color)> poiTypeStyles,
      })?> getHomeData(String userProfileId) async {

    final clusterData =
        await _clusterService.getClusterIdByUserProfileId(userProfileId);

    log.fine("^^^^^ clusterData: $clusterData");

    Iterable<dynamic>? captains;
    Cluster? cluster;

    final groups = clusterData?['people']['people_groups'];
    if (groups != null) {
      final clusterId = groups['households']['cluster_id'];
      log.fine("^^^^^ clusterId: $clusterId");

      if (clusterId != null) {
        cluster = await clusterRepo.getCluster(clusterId);
        log.fine("^^^^^ cluster: $cluster");
      }

      final captainsData =
          await _clusterService.getCaptainsByClusterId(clusterId);
      captains =
          captainsData?.map((row) => row['captain']['user_profile']['person']);
    }

    log.fine('getHomeData: fetching pointsOfInterest for $userProfileId');
    final pointsOfInterest = await _poiService.getPointsOfInterest(
      userProfileId,
    );
    log.fine('getHomeData: got ${pointsOfInterest.length} pointsOfInterest');

    log.fine('getHomeData: fetching poiTypeStyles');
    final poiTypeStyles = await _poiService.getPointOfInterestTypes();
    log.fine('getHomeData: got ${poiTypeStyles.length} poiTypeStyles');

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
      poiTypeStyles: poiTypeStyles,
    );
  }

  Future<List<PointOfInterest>> getPointsOfInterest(
    String userProfileId,
  ) {
    return _poiService.getPointsOfInterest(userProfileId);
  }

  Future<Map<String, (FaIconData, Color)>> getPointOfInterestTypes() {
    return _poiService.getPointOfInterestTypes();
  }
}
