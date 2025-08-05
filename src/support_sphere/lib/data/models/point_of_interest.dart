import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ionicons/ionicons.dart';
//import 'package:font_awesome_flutter/name_icon_mapping.dart';

class PointOfInterest extends Equatable {
  final String id;
  final String name;
  final String address;
  final LatLng geom;
  final String type;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.address,
    required this.geom,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, address, geom, type];

  PointOfInterest copyWith({
    required String id,
    required String name,
    required String address,
    required LatLng geom,
    required String type,
  }) {
    return PointOfInterest(
      id: id,
      name: name,
      address: address,
      geom: geom,
      type: type,
    );
  }

  Marker marker() {
    return Marker(
      point: geom,
      width: 40,
      height: 40,
      // child: FaIcon(faIconNameMapping[type]);
      child: const Icon(
        Ionicons.terminal_outline,
        color: Colors.red,
        size: 40,
      ));
  }
}
