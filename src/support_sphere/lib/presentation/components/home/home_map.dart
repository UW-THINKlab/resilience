import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/data/models/captain_marker.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';

import 'dart:developer' as dev;

class HomeMap extends StatelessWidget {
  final MapController mapController;
  final LatLng? userLocation;
  final LatLng initMapCentroid;
  final double initZoomLevel;
  final List<CaptainMarker>? captainMarkers;
  final List<PointOfInterest>? pointsOfInterest;
  final VoidCallback? onMapReady;

  const HomeMap({
    super.key,
    required this.mapController,
    this.userLocation,
    required this.initMapCentroid,
    required this.initZoomLevel,
    this.captainMarkers,
    this.pointsOfInterest,
    this.onMapReady,
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
      print(value);
      return value;
    }
  }
}
