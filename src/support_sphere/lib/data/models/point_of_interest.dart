import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart' show Logger;

final log = Logger('MessagesPage');

const double default_icon_size = 40;



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

const Map<String, (IconData, Color)> _icons = {
  "building-shield": (FontAwesomeIcons.buildingShield, Colors.blueGrey),
  "school": (FontAwesomeIcons.school, Colors.blue),
  "building-columns": (FontAwesomeIcons.buildingColumns, Colors.lightGreen),
  "hospital": (FontAwesomeIcons.hospital, Colors.red),
  "place-of-worship": (FontAwesomeIcons.placeOfWorship, Colors.orange),
  "building-flag": (FontAwesomeIcons.buildingFlag, Colors.green),
  "circle-user": (FontAwesomeIcons.circleUser, Colors.purple),
  "user": (FontAwesomeIcons.buildingShield, Colors.blueGrey),
  // NOTE: hacky work around until I put the "type" forien ke in place
  "community center": (FontAwesomeIcons.buildingFlag, Colors.green),
  "church": (FontAwesomeIcons.placeOfWorship, Colors.orange),
  "meeting-place": (FontAwesomeIcons.personRays, Colors.green)
};


class PointOfInterest extends Equatable {
  final String id;
  final String name;
  final String address;
  final String description;
  final LatLng geom;
  final String type;
  final double size = default_icon_size;

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
    FaIcon icon;
    Color color;
    if (_icons[type] != null) {
      final (ico,colo) = _icons[type]!;
      icon = FaIcon(ico, size: size/1.75, color: Colors.white);
      color = colo;
    }
    else {
      log.warning("Unknown icon type: $name");
      icon = FaIcon(FontAwesomeIcons.atom, color: Colors.white);
      color = Colors.purple;
    }

    return Marker(
      point: geom,
      width: size,
      height: size,
      child: CircleAvatar(
        backgroundColor: color,
        child: Center(child: icon),
      )
    );
  }

  static Marker markerFor(LatLng geom, name, String color) {
    FaIcon icon;
    Color color;
    const size = default_icon_size;
    if (_icons[name] != null) {
      final (ico,colo) = _icons[name]!;
      icon = FaIcon(ico, size: size/1.75, color: Colors.white);
      color = colo;
    }
    else {
      log.warning("Unknown icon type: $name");
      icon = FaIcon(FontAwesomeIcons.atom, color: Colors.white);
      color = Colors.purple;
    }

    return Marker(
      point: geom,
      width: size,
      height: size,
      child: CircleAvatar(
        backgroundColor: color,
        child: Center(child: icon),
      )
    );

  }
}
