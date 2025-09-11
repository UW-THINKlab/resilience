import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:logging/logging.dart';
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
        // FIXME on fresh map
        initialCenter: state.initMapCentroid,
        initialZoom: state.initZoomLevel,
        onMapReady: onMapReady,
        onTap: (_, latLng) {
            final point = mapController.camera.latLngToScreenOffset(latLng);
            final offset = Offset(point.dx, point.dy);
            cubit.setMeetingPlace(latLng, offset);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: appUserAgent
        ),
        PolygonLayer(
          polygons: _generatePolygons(),
        ),
        MarkerLayer(
          markers: [
            if (state.userLocation != null) _buildUserMarker(state.userLocation!),
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
        Ionicons.person,
        color: Colors.black,
        size: 40,
      ),
    );
  }

  Marker _buildCaptainMarker(BuildContext context, CaptainMarker captainMarker) {
    return Marker(
      point: captainMarker.householdGeom!,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showCaptainDetails(context, captainMarker),
        child: const Icon(
          Ionicons.person,
          color: Colors.green,
          size: 40,
        ),
      ),
    );
  }

  void _showCaptainDetails(BuildContext context, CaptainMarker captain) {
    // TODO: implement showing a dialog with captain details
  }

  // void _editMode(HomeState state) {
  //   if (state.cluster != null && state.cluster!.geom != null ) {
  //     LatLngBounds? bounds = LatLngBounds.fromPoints(state.cluster!.geom!);
  //     mapController.fitCamera(CameraFit.bounds(bounds: bounds));
  //   }
  // }

  List<Marker> _buildPointsOfInterest() {
    if (state.pointsOfInterest == null) {
      return [];
    }
    else {
      var value = [for (var p in state.pointsOfInterest!) p.marker()];
      //dev.log(value.toString());
      //print(value);
      //log.fine(value.toString());
      return value;
    }
  }

  Polygon? clusterPolygon(Cluster cluster) {
    if (cluster.geom == null) return null;

    // random color
    // could be based on hash of cluster name
    // or cluster geometry
    final color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    return Polygon(
        label: cluster.name,
        points: cluster.geom!,
        color: color.withAlpha(64),
        borderColor: color,
        borderStrokeWidth: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: color.shade900),
    );
  }

  //late var _polygonsRaw = generatePolygons();
  List<Polygon> _generatePolygons() {
    List<Polygon> polygons = [];

    if (state.allClusters != null && state.allClusters!.isNotEmpty) {
      for (var cluster in state.allClusters!) {
        final poly = clusterPolygon(cluster);
        if (poly != null) {
          polygons.add(poly);
        }
      }
    }

    return polygons;
  }
}
