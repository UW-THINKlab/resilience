import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ionicons/ionicons.dart';
//import 'package:font_awesome_flutter/name_icon_mapping.dart';

// Need a lookup map for icon colors
const Map<String, Color> colorStringToColor = {
    'amber': Colors.amber,
    'amberAccent': Colors.amberAccent,
    'black': Colors.black,
    'black12': Colors.black12,
    'black26': Colors.black26,
    'black38': Colors.black38,
    'black45': Colors.black45,
    'black54': Colors.black54,
    'black87': Colors.black87,
    'blue': Colors.blue,
    'blueAccent': Colors.blueAccent,
    'blueGrey': Colors.blueGrey,
    'brown': Colors.brown,
    'cyan': Colors.cyan,
    'cyanAccent': Colors.cyanAccent,
    'deepOrange': Colors.deepOrange,
    'deepOrangeAccent': Colors.deepOrangeAccent,
    'deepPurple': Colors.deepPurple,
    'deepPurpleAccent': Colors.deepPurpleAccent,
    'green': Colors.green,
    'greenAccent': Colors.greenAccent,
    'grey': Colors.grey,
    'indigo': Colors.indigo,
    'indigoAccent': Colors.indigoAccent,
    'lightBlue': Colors.lightBlue,
    'lightBlueAccent': Colors.lightBlueAccent,
    'lightGreen': Colors.lightGreen,
    'lightGreenAccent': Colors.lightGreenAccent,
    'lime': Colors.lime,
    'limeAccent': Colors.limeAccent,
    'orange': Colors.orange,
    'orangeAccent': Colors.orangeAccent,
    'pink': Colors.pink,
    'pinkAccent': Colors.pinkAccent,
    'purple': Colors.purple,
    'purpleAccent': Colors.purpleAccent,
    'red': Colors.red,
    'redAccent': Colors.redAccent,
    'teal': Colors.teal,
    'tealAccent': Colors.tealAccent,
    'transparent': Colors.transparent,
    'white': Colors.white,
    'white10': Colors.white10,
    'white12': Colors.white12,
    'white24': Colors.white24,
    'white30': Colors.white30,
    'white38': Colors.white38,
    'white54': Colors.white54,
    'white60': Colors.white60,
    'white70': Colors.white70,
    'yellow': Colors.yellow,
    'yellowAccent': Colors.yellowAccent,
};

class PointOfInterest extends Equatable {
  final String id;
  final String name;
  final String address;
  final String description;
  final LatLng geom;
  final String type;

  const PointOfInterest({
    required this.id,
    required this.name,
    this.address = "",
    this.description = "",
    required this.geom,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, address, description, geom, type];

  PointOfInterest copyWith({
    required String id,
    required String name,
    required String address,
    required String description,
    required LatLng geom,
    required String type,
  }) {
    return PointOfInterest(
      id: id,
      name: name,
      address: address,
      description: description,
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
        Ionicons.terminal,
        color: Colors.deepPurple,
        size: 40,
      ));
  }
}
