import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

final httpClient = RetryClient(Client());

// TODO research https://operations.osmfoundation.org/policies/tiles/, confirm attribution
TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      tileProvider: NetworkTileProvider(httpClient: httpClient),
    );

enum HomePageStatus { initial, loading, success, edit, failure }

// if cluster, center cluster rect on cluster geom
// if no cluster or geom, default to:
const defaultInitMapCentroid = LatLng(47.661322762238285, -122.2772993912835);

class Home2Page extends StatefulWidget {
  static const String route = '/home2';

  const Home2Page({super.key});

  @override
  State<Home2Page> createState() =>
      _HomePageState();
}

class _HomePageState extends State<Home2Page> {
  _HomePageState({
    this.status = HomePageStatus.initial,
    this.userLocation,
    this.initMapCentroid = defaultInitMapCentroid,
    //this.initZoomLevel = 17.5,
    //this.captainMarkers,
    //this.cluster,
    //this.pointsOfInterest,
  });
  static const double pointSize = 65;

  final mapController = MapController();

  // from orig
  final HomePageStatus status;
  LatLng? userLocation;
  LatLng? initMapCentroid;
  double? initZoomLevel;
  //final List<CaptainMarker>? captainMarkers;
  //final Cluster? cluster;
  //final List<PointOfInterest>? pointsOfInterest;

  // from edit mode
  LatLng? tappedCoords;
  Offset? tappedPoint;

  @override
  void initState() {
    super.initState();

    if (userLocation != null) {
      initMapCentroid = userLocation;
    }
    // fallback to cluster

    //SchedulerBinding.instance
    //    .addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(
    //          const SnackBar(content: Text('Tap/click to set coordinate')),
    //        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('#TODO Name from cluster')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initMapCentroid!,
              initialZoom: initZoomLevel!,
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.doubleTapZoom,
              ),
              onTap: (_, latLng) {
                final point = mapController.camera
                    .latLngToScreenOffset(tappedCoords = latLng);
                setState(() => tappedPoint = Offset(point.dx, point.dy));
              },
            ),
            children: [
              openStreetMapTileLayer,
              if (tappedCoords != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: pointSize,
                      height: pointSize,
                      point: tappedCoords!,
                      child: const Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
            ],
          ),
          if (tappedPoint != null)
            Positioned(
              left: tappedPoint!.dx - 60 / 2,
              top: tappedPoint!.dy - 60 / 2,
              child: const IgnorePointer(
                child: Icon(
                  Icons.center_focus_strong_outlined,
                  color: Colors.black,
                  size: 60,
                ),
              ),
            )
        ],
      ),
    );
  }
}
