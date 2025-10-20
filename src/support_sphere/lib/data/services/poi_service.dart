
import 'package:support_sphere/utils/supabase.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';

class PointOfInterestService {
  //final SupabaseClient _supabaseClient = supabase;
  static const String collection = 'point_of_interests';

  // Future<PostgrestList?> queryPointsOfInterest() async {
  //   return await supabase.from(collection).select().order('name', ascending: true);
  // }

  Future<void> insert(PointOfInterest poi) async {
    await supabase.from(collection).insert(poi.toMap());
  }

  // LatLng geometryFromMap(Map geomMap) {
  //   // "geom" -> Map (2 items)
  //   //     "type" -> "Point"
  //   //     "coordinates" -> List (2 items)
  //   //       47.6591528763917
  //   //       -122.27787227416428
  //   // geom:{"type:x", "coordinates":[lat,long]}
  //   return LatLng(geomMap["coordinates"][0], geomMap["coordinates"][1]);
  // }

  // PointOfInterest fromMap(Map poiMap) {
  //   var geomMap = poiMap['geom'];
  //   var geom = geometryFromMap(geomMap);
  //   return PointOfInterest(
  //     id:poiMap['id'],
  //     name:poiMap['name'],
  //     address:poiMap['address'],
  //     geom: geom,
  //     type:poiMap['point_type_name']);
  // }

  Future<List<PointOfInterest>> getPointsOfInterest() async {
    final points = await supabase.from(collection).select().order('name', ascending: true);
    return [for (var p in points) PointOfInterest.fromMap(p)];
  }

  // FIXME: Add query based on user location
  Future<List<PointOfInterest>> near(double distanceInMeters) async {
    // TODO: Add distance based query !!!
    var points = await supabase.from(collection).select().order('name', ascending: true);
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
