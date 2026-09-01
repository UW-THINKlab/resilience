import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:support_sphere/constants/color.dart' show ColorConstants;
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/presentation/components/confirmation_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:logging/logging.dart';
import 'package:support_sphere/data/models/point_of_interest.dart';
import 'package:support_sphere/data/services/poi_service.dart';
import 'package:support_sphere/logic/cubit/home_cubit.dart';
import 'package:support_sphere/presentation/pages/main_app/home/add_point_of_interest_sheet.dart';
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
          } else if (state.status == HomeStatus.addPointOfInterest) {
            cubit.cancelAddPointOfInterest();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: AddPointOfInterestSheet(
                  authUser: cubit.authUser,
                  availableTypes: state.poiTypeStyles.keys
                      .where((t) => t != "cluster meeting point")
                      .toList(),
                  center: latLng,
                  onSave: () => cubit.refreshPointsOfInterest(),
                ),
              ),
            );
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: appUserAgent,
        ),
        PolygonLayer(polygons: _generatePolygons()),
        MarkerLayer(
          markers: [
            if (state.userLocation != null)
              _buildUserMarker(state.userLocation!),
            if (state.cluster?.meetingPoint != null)
              buildMeetingMarker(
                context,
                state.cluster?.meetingPlace,
                state.cluster?.meetingPoint,
              ),
            // ...state.captainMarkers!
            //     .where((marker) => marker.householdGeom != null)
            //     .map((marker) => _buildCaptainMarker(
            //           context,
            //           marker,
            //         )),
            ..._buildPointsOfInterest(context),
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
      child: const Icon(Icons.person, color: Colors.black, size: 40),
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

  void _showDetailsDialog(
    BuildContext context,
    String title,
    List<Widget> details,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...details,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPoiDetailsDialog(BuildContext context, PointOfInterest poi) {
    final canDelete = poi.userId == cubit.authUser.uuid ||
        cubit.authUser.userRole == AppRoles.communityAdmin;

    _showDetailsDialog(context, poi.name, [
      Text('${PoiDetailsDialogStrings.type}: ${poi.type}'),
      if (poi.address.isNotEmpty)
        Text('${PoiDetailsDialogStrings.address}: ${poi.address}'),
      if (poi.notes != null && poi.notes!.isNotEmpty)
        Text('${PoiDetailsDialogStrings.notes}: ${poi.notes}'),
      if (poi.expiresAt != null)
        Text(AddPointOfInterestFormStrings.expiresOn(poi.expiresAt!)),
      Text('${PoiDetailsDialogStrings.visibility}: ${poi.visibilityScope.name}'),
      if (canDelete) ...[
        const SizedBox(height: 12),
        Center(
          child: ConfirmButton(
            label: PoiDetailsDialogStrings.delete,
            color: ColorConstants.dangerRed,
            onPressed: () async {
              final confirmed = await ConfirmationDialog(
                title: const Text(PoiDetailsDialogStrings.confirmDeleteTitle),
                content: const Text(
                  PoiDetailsDialogStrings.confirmDeleteMessage,
                ),
                actions: [
                  CancelButton(
                    label: AddPointOfInterestFormStrings.cancel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ConfirmButton(
                    label: PoiDetailsDialogStrings.delete,
                    color: ColorConstants.dangerRed,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ).show<bool>(context);
              if (confirmed != true) return;

              await PointOfInterestService().delete(poi.id);
              if (context.mounted) Navigator.of(context).pop();
              cubit.refreshPointsOfInterest();
            },
          ),
        ),
      ],
    ]);
  }

  void _showMeetingPointDetailsDialog(
    BuildContext context,
    String label,
    String? description,
  ) {
    _showDetailsDialog(context, label, [
      if (description != null && description.isNotEmpty)
        Text('${PoiDetailsDialogStrings.notes}: $description'),
    ]);
  }

  List<Marker> _buildPointsOfInterest(BuildContext context) {
    if (state.pointsOfInterest == null) {
      return [];
    } else {
      var value = [
        for (var p in state.pointsOfInterest!)
          p.marker(
            state.poiTypeStyles,
            onTap: () => _showPoiDetailsDialog(context, p),
          ),
      ];

      // Append geojson points
      if (state.geojson != null) {
        for (final entry in state.geojson!.entries) {
          if (entry.key != null) {
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

    // deterministic per-cluster color, so it stays stable across rebuilds
    final color =
        Colors.primaries[cluster.id.hashCode.abs() % Colors.primaries.length];

    //log.fine("Cluster polygon: ${cluster.name} ${cluster.geom}");
    // HACK: There have been some problems in the data, with latitude and longitude getting reversed.
    // This is an attempt simple check to warn and skip.
    final LatLngBounds? bounds = clusterBounds(cluster);
    if (bounds != null && bounds.south < -90) {
      log.warning("Cannot render invalid cluster geometry -  ${cluster.name}");
      return null;
    } else {
      return Polygon(
        label: cluster.name,
        points: cluster.geom!,
        color: color.withAlpha(64),
        borderColor: color,
        borderStrokeWidth: 3,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: color.shade900,
        ),
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
        if (entry.key != null) {
          // TODO: Add check for if layer is visible.
          polygons.addAll(entry.value.polygons);
          log.fine("adding geojson polygon layer: ${entry.key}");
        }
      }
    }

    return polygons;
  }

  Marker buildMeetingMarker(
    BuildContext context,
    String? meetingPlace,
    LatLng? meetingPoint,
  ) {
    log.fine("Building meeting marker: $meetingPlace, $meetingPoint");
    final clusterName = state.cluster?.name;
    final label = (clusterName != null && clusterName.isNotEmpty)
        ? "cluster $clusterName meeting point"
        : "cluster meeting point";
    return PointOfInterest.markerFor(
      meetingPoint!,
      "cluster meeting point",
      state.poiTypeStyles,
      label: label,
      onTap: () =>
          _showMeetingPointDetailsDialog(context, label, meetingPlace),
    );
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
    BuildContext context,
    HomeCubit cubit,
  ) async {
    String description = "";
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text(SaveMeetingPointDialogStrings.title),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(SaveMeetingPointDialogStrings.descriptionLabel),
                const SizedBox(height: 15),
                TextFormField(
                  onChanged: (value) => description = value,
                  decoration: InputDecoration(
                    labelText: SaveMeetingPointDialogStrings.description,
                    //icon: Icon(Icons.message ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CancelButton(
            label: SaveMeetingPointDialogStrings.cancel,
            onPressed: () {
              cubit.cancelMeetingPlace();
              Navigator.pop(context);
            },
          ),
          ConfirmButton(
            label: SaveMeetingPointDialogStrings.save,
            onPressed: () {
              cubit.saveMeetingPlace(description);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
