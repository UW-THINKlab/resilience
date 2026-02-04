import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class CaptainMarker extends Equatable {
  final String id;
  final String familyName;
  final String givenName;

  /// We store the polygon geometry in the database,
  /// however, we only need the centroid of the polygon to display the marker on the map
  /// so we use "Geodesy" to calculate it and store the centroid of the polygon as `householdGeom` here
  final LatLng? householdGeom;

  const CaptainMarker({
    required this.id,
    required this.familyName,
    required this.givenName,
    this.householdGeom,
  });

  @override
  List<Object?> get props => [id, familyName, givenName, householdGeom];

  CaptainMarker copyWith({
    required String id,
    required String familyName,
    required String givenName,
    LatLng? householdGeom,
  }) {
    return CaptainMarker(
      id: id,
      familyName: familyName,
      givenName: givenName,
      householdGeom: householdGeom,
    );
  }
}
