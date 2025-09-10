import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';

enum HomeStatus { initial, loading, success, editMeetingPlace, allClusters, failure }

// we assume that the user will provide permission to access their location for now
// but still need to set a default map centroid such as the cluster's geometry
// so the user who doesn't provide permission can still see captains' locations (even though there is no marker for current user's location)
// map default: if cluster meetingpoint, use cluster meetinpoint
// if cluster, center cluster rect on cluster geom
// if no cluster or geom, default to:
const defaultInitMapCentroid = LatLng(47.658, -122.2772993912835);

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userLocation,
    this.initMapCentroid = defaultInitMapCentroid,
    this.initZoomLevel = 15.6,
    this.captainMarkers,
    this.cluster,
    this.pointsOfInterest,
    this.allClusters,
    this.pickedLocation,
  });

  final HomeStatus status;
  final LatLng? userLocation;
  final LatLng initMapCentroid;
  final double initZoomLevel;
  final List<CaptainMarker>? captainMarkers;
  final Cluster? cluster;
  final List<PointOfInterest>? pointsOfInterest;
  final List<Cluster>? allClusters;
  final LatLng? pickedLocation;


  @override
  List<Object?> get props => [
        status,
        userLocation,
        initMapCentroid,
        initZoomLevel,
        captainMarkers,
        cluster,
        pointsOfInterest,
        allClusters,
        pickedLocation,
      ];

  HomeState copyWith({
    HomeStatus? status,
    LatLng? userLocation,
    LatLng? initMapCentroid,
    double? initZoomLevel,
    List<CaptainMarker>? captainMarkers,
    Cluster? cluster,
    List<PointOfInterest>? pointsOfInterest,
    List<Cluster>? allClusters,
    LatLng? pickedLocation,
  }) {
    return HomeState(
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      initMapCentroid: initMapCentroid ?? this.initMapCentroid,
      initZoomLevel: initZoomLevel ?? this.initZoomLevel,
      captainMarkers: captainMarkers ?? this.captainMarkers,
      cluster: cluster ?? this.cluster,
      pointsOfInterest: pointsOfInterest ?? this.pointsOfInterest,
      allClusters: allClusters ?? this.allClusters,
    );
  }
}
