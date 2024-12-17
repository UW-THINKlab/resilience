import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/models/clusters.dart';

enum HomeStatus { initial, loading, success, failure }

// TODO: Replace the default init map centroid
// we assume that the user will provide permission to access their location for now
// but still need to set a default map centroid such as the cluster's geometry
// so the user who doesn't provide permission can still see captains' locations (even though there is no marker for current user's location)
const defaultInitMapCentroid = LatLng(47.6062, -122.3321);

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userLocation,
    this.initMapCentroid = defaultInitMapCentroid,
    this.initZoomLevel = 17.5,
    this.captainMarkers,
    this.cluster,
  });

  final HomeStatus status;
  final LatLng? userLocation;
  final LatLng initMapCentroid;
  final double initZoomLevel;
  final List<CaptainMarker>? captainMarkers;
  final Cluster? cluster;

  @override
  List<Object?> get props => [
        status,
        userLocation,
        initMapCentroid,
        initZoomLevel,
        captainMarkers,
        cluster,
      ];

  HomeState copyWith({
    HomeStatus? status,
    LatLng? userLocation,
    LatLng? initMapCentroid,
    double? initZoomLevel,
    List<CaptainMarker>? captainMarkers,
    Cluster? cluster,
  }) {
    return HomeState(
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      initMapCentroid: initMapCentroid ?? this.initMapCentroid,
      initZoomLevel: initZoomLevel ?? this.initZoomLevel,
      captainMarkers: captainMarkers ?? this.captainMarkers,
      cluster: cluster ?? this.cluster,
    );
  }
}
