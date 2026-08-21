import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart' show Color;
import 'package:support_sphere/data/models/generated_classes.dart'
    show POI_CATEGORY;
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';

class PointOfInterestService {
  static const String collection = 'point_of_interests';
  static const String typesCollection = 'point_of_interest_types';

  Future<void> insert(PointOfInterest poi) async {
    await supabase.from(collection).insert(poi.toMap());
  }

  Future<List<PointOfInterest>> getPointsOfInterest(
    String requesterProfileId,
  ) async {
    log.fine(
      'getPointsOfInterest: calling get_visible_points_of_interest rpc '
      'for $requesterProfileId',
    );
    final points = await supabase
        .rpc(
          'get_visible_points_of_interest',
          params: {'p_requester_profile_id': requesterProfileId},
        )
        .order('name', ascending: true);
    log.fine('getPointsOfInterest: rpc returned ${points.length} rows: $points');
    return [for (var p in points) PointOfInterest.fromMap(p)];
  }

  Future<Map<String, (FaIconData, Color)>> getPointOfInterestTypes() async {
    final rows = await supabase.from(typesCollection).select();
    final styles = <String, (FaIconData, Color)>{};
    for (final row in rows) {
      final icon = iconBySlug[row['icon']];
      final category = row['category'] != null
          ? POI_CATEGORY.values.byName(row['category'].toString())
          : null;
      final color = category != null ? colorByCategory[category] : null;
      if (icon != null && color != null) {
        styles[row['name']] = (icon, color);
      } else {
        log.warning('Unresolvable POI type style: ${row['name']}');
      }
    }
    return styles;
  }

  // FIXME: Add query based on user location
  Future<List<PointOfInterest>> near(double distanceInMeters) async {
    // TODO: Add distance based query !!!
    var points = await supabase
        .from(collection)
        .select()
        .order('name', ascending: true);
    return [for (var p in points) PointOfInterest.fromMap(p)];
  }

  // select id,
  // name,
  // gis.st_y(location::gis.geometry) as lat,
  // gis.st_x(location::gis.geometry) as long
  // from public.restaurants
  // where location operator(gis.&&)
  // gis.ST_SetSRID(gis.ST_MakeBox2D(gis.ST_Point(min_long, min_lat), gis.ST_Point(max_long, max_lat)), 4326)

  // final pointsOfInterest = await _poiService.getPointsOfInterest();

  // final captainsData = await _clusterService.getCaptainsByClusterId(clusterId);
  // final captains = captainsData?.map((row) => row['captain']['user_profile']['person']);
  //   return (
  //     captainMarkers: captains
  //         ?.map((captain) => CaptainMarker(
  //               id: captain['id'],
  //               familyName: captain['family_name'],
  //               givenName: captain['given_name'],
  //               householdGeom: captain['people_groups']['households']['geom'] != null
  //                   ? PolygonCentroid.findPolygonCentroid(
  //                       captain['people_groups']['households']['geom']['coordinates'][0]
  //                           .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
  //                           .toList())
  //                   : null,
  //             ))
  //         .toList(),
  //     cluster: userCluster != null ? Cluster.fromJson(userCluster) : null,
  //   );
}
