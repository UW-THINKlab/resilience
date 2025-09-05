import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';
import 'package:logging/logging.dart';
import 'dart:math';

import 'dart:developer' as dev;

const appUserAgent = "edu.uw.thinklab.resilience";

final log = Logger('HomeMap');


class HomeMap extends StatelessWidget {
  final MapController mapController;
  final LatLng? userLocation;
  final LatLng initMapCentroid;
  final double initZoomLevel;
  final List<CaptainMarker>? captainMarkers;
  final List<PointOfInterest>? pointsOfInterest;
  final VoidCallback? onMapReady;
  final Cluster? cluster;
  final List<Cluster>? allClusters;

  const HomeMap({
    super.key,
    required this.mapController,
    this.userLocation,
    required this.initMapCentroid,
    required this.initZoomLevel,
    this.captainMarkers,
    this.pointsOfInterest,
    this.cluster,
    this.onMapReady,
    this.allClusters,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initMapCentroid,
        initialZoom: initZoomLevel,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: appUserAgent,
        ),
        MarkerLayer(
          markers: [
            if (userLocation != null) _buildUserMarker(userLocation!),
            ...captainMarkers!
                .where((marker) => marker.householdGeom != null)
                .map((marker) => _buildCaptainMarker(
                      context,
                      marker,
                    )),
            ..._buildPointsOfInterest(),
          ],
        ),
        PolygonLayer(
          polygons: (allClusters != null) ? _generatePolygons(allClusters) : _generatePolygons([cluster!]),
        )
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

  List<Marker> _buildPointsOfInterest() {
    if (pointsOfInterest == null) {
      return [];
    }
    else {
      var value = [for (var p in pointsOfInterest!) p.marker()];
      dev.log(value.toString());
      //print(value);
      log.fine(value.toString());
      return value;
    }
  }

  //late var _polygonsRaw = generatePolygons();
  List<Polygon> _generatePolygons(List<Cluster>? clusters) {
    // TODO check display toggle
    List<Polygon> polygons = [];
    if (clusters == null || clusters.isEmpty) return [];

    for (var cluster in clusters) {
      if (cluster.geom != null) {
        final color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
        polygons.add(
          Polygon(
              label: cluster.name,
              points: cluster.geom!,
              color: color.withAlpha(64),
              borderColor: color,
              borderStrokeWidth: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: color.shade900),
            )
        );
      }
    }
    //print("#### ${polygons[0]}");
    return polygons;
  }
}
