import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:logging/logging.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';
import 'package:support_sphere/logic/cubit/home_cubit.dart';
import 'dart:math';

import 'package:support_sphere/logic/cubit/home_state.dart';

const appUserAgent = "edu.uw.thinklab.resilience";

final log = Logger('HomeMap');

class HomeMap extends StatelessWidget {
  final MapController mapController;
  final VoidCallback? onMapReady;
  final HomeState state;
  final HomeCubit cubit;

  const HomeMap({
    super.key,
    required this.mapController,
    required this.onMapReady,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: state.initMapCentroid,
        initialZoom: state.initZoomLevel,
        onMapReady: onMapReady,
        onTap: (_, latLng) {
          if (state.status == HomeStatus.editMeetingPlace) {
            final point = mapController.camera.latLngToScreenPoint(latLng);
            final offset = Offset(point.x, point.y);
            cubit.setMeetingPlace(latLng, offset);
            // FIXME - popup dialog for description
            //cubit.saveMeetingPlace(); // TODO move to dialog popup
            _popupDescriptionDialog(context, cubit);
          }
        },
      ),
      children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: appUserAgent),
        PolygonLayer(
          polygons: _generatePolygons(),
        ),
        MarkerLayer(
          markers: [
            if (state.userLocation != null)
              _buildUserMarker(state.userLocation!),
            if (state.cluster?.meetingPoint != null)
              buildMeetingMarker(
                  state.cluster?.meetingPlace, state.cluster?.meetingPoint),
            // ...state.captainMarkers!
            //     .where((marker) => marker.householdGeom != null)
            //     .map((marker) => _buildCaptainMarker(
            //           context,
            //           marker,
            //         )),
            ..._buildPointsOfInterest(),
          ],
        ),
      ],
    );
  }

  Marker _buildUserMarker(LatLng location) {
    return Marker(
      point: location,
      width: 40,
      height: 40,
      child: const Icon(
        Icons.person,
        color: Colors.black,
        size: 40,
      ),
    );
  }

  // Marker _buildCaptainMarker(BuildContext context, CaptainMarker captainMarker) {
  //   return Marker(
  //     point: captainMarker.householdGeom!,
  //     width: 40,
  //     height: 40,
  //     child: GestureDetector(
  //       onTap: () => _showCaptainDetails(context, captainMarker),
  //       child: const Icon(
  //         Icons.person,
  //         color: Colors.green,
  //         size: 40,
  //       ),
  //     ),
  //   );
  // }

  // void _showCaptainDetails(BuildContext context, CaptainMarker captain) {
  //   // TODO: implement showing a dialog with captain details
  // }

  // void _editMode(HomeState state) {
  //   if (state.cluster != null && state.cluster!.geom != null ) {
  //     LatLngBounds? bounds = LatLngBounds.fromPoints(state.cluster!.geom!);
  //     mapController.fitCamera(CameraFit.bounds(bounds: bounds));
  //   }
  // }

  List<Marker> _buildPointsOfInterest() {
    if (state.pointsOfInterest == null) {
      return [];
    } else {
      var value = [for (var p in state.pointsOfInterest!) p.marker()];

      // Append geojson points
      if (state.geojson != null) {
        for (final entry in state.geojson!.entries) {
          if (entry.key != null ) {
            // FIXME check if layer is enabled
            value.addAll(entry.value.markers);
            log.fine("Loaded geojson feature: $entry");
          }
        }
      }

      return value;
    }
  }

  LatLngBounds? clusterBounds(Cluster cluster) {
    double maxLat = 0;
    double maxLng = 0;
    double minLat = 100;
    double minLng = 100;

    if (cluster.geom != null) {
      for (var point in cluster.geom!) {
        maxLat = max(maxLat, point.latitude);
        minLat = min(minLat, point.latitude);
        maxLng = max(maxLng, point.longitude);
        minLng = min(minLng, point.longitude);
      }
    }

    if (minLat < -90.0) {
      log.warning("Cannot render invalid cluster geometry -  ${cluster.name}");
      return null;
    }

    LatLng maxPoint = LatLng(maxLat, maxLng);
    LatLng minPoint = LatLng(minLat, minLng);
    return LatLngBounds(minPoint, maxPoint);
  }

  Polygon? clusterPolygon(Cluster cluster) {
    if (cluster.geom == null) return null;

    // random color
    // could be based on hash of cluster name
    // or cluster geometry
    final color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    // FIXME: Provide a better way to color cluster polygons

    //log.fine("Cluster polygon: ${cluster.name} ${cluster.geom}");
    // HACK: There have been some problems in the data, with latitude and longitude getting reversed.
    // This is an attempt simple check to warn and skip.
    final LatLngBounds? bounds = clusterBounds(cluster);
    if (bounds != null && bounds.south < -90) {
      log.warning("Cannot render invalid cluster geometry -  ${cluster.name}");
      return null;
    }
    else {
      return Polygon(
        label: cluster.name,
        points: cluster.geom!,
        color: color.withAlpha(64),
        borderColor: color,
        borderStrokeWidth: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: color.shade900),
      );
    }
  }

  List<Polygon> _generatePolygons() {
    List<Polygon> polygons = [];

    //log.fine("generating polygons: ${state.geojson}");

    if (state.allClusters != null && state.allClusters!.isNotEmpty) {
      for (var cluster in state.allClusters!) {
        final poly = clusterPolygon(cluster);
        if (poly != null) {
          polygons.add(poly);
        }
      }
    }

    // Add geojson polygons
    if (state.geojson != null) {
      for (final entry in state.geojson!.entries) {
        if (entry.key != null ) {
          // TODO: Add check for if layer is visible.
          polygons.addAll(entry.value.polygons);
          log.fine("adding geojson polygon layer: ${entry.key}");
        }
      }
    }

    return polygons;
  }

  Marker buildMeetingMarker(String? meetingPlace, LatLng? meetingPoint) {
    log.fine("Building meeting marker: $meetingPlace, $meetingPoint");
    return PointOfInterest.markerFor(meetingPoint!, "meeting-place", "green");
    // const iconSize = 40.0; // FIXME - move to general constant
    // return Marker(
    //   point: meetingPoint!,
    //   width: iconSize,
    //   height: iconSize,
    //   child: const Icon(
    //     Icons.people_circle_outline,
    //     color: Colors.green,
    //     size: iconSize,
    //   ),
    //   // child: GestureDetector(
    //   //   //onTap: () => _showCaptainDetails(context, captainMarker),
    //   //   child: const Icon(
    //   //     Icons.person,
    //   //     color: Colors.green,
    //   //     size: iconSize,
    //   //   ),
    //   // ),
    // );
  }

  Future<void> _popupDescriptionDialog(
      BuildContext context, HomeCubit cubit) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              scrollable: true,
              title: Text('Save meeting point location?'),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Enter description for '),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          //icon: Icon(Icons.message ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CancelButton(
                    label: 'Cancel',
                    onPressed: () {
                      cubit.cancelMeetingPlace();
                      Navigator.pop(context);
                    }),
                ConfirmButton(
                    label: 'Save',
                    onPressed: () {
                      // FIXME: get description from form!
                      final description = "";
                      cubit.saveMeetingPlace(description);
                      Navigator.pop(context);
                    }),
              ],
            ));
  }
}
