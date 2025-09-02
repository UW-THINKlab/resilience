import 'package:equatable/equatable.dart';
import 'package:geodesy/geodesy.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:logging/logging.dart';

final log = Logger('Cluster');

class Cluster extends Equatable {

  const Cluster({
    required this.id,
    this.name = '',
    this.meetingPlace = '',
    this.notes = '',
    this.geom,
    this.meetingPoint,
    this.captains,
  });

  /// The current user's id, which matches the auth user id
  final String id;
  final String? name;
  final String? meetingPlace;
  final String? notes;
  final List<LatLng>? geom;
  final LatLng? meetingPoint;
  final Captains? captains;

  @override
  List<Object?> get props => [id, name, meetingPlace, notes, geom, meetingPoint, captains];

  Cluster copyWith({
    String? id,
    String? name,
    String? meetingPlace,
    String? notes,
    List<LatLng>? geom,
    LatLng? meetingPoint,
    Captains? captains,
  }) {
    return Cluster(
      id: id ?? this.id,
      name: name ?? this.name,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      notes: notes ?? this.notes,
      geom: geom ?? this.geom,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      captains: captains ?? this.captains,
    );
  }

  factory Cluster.fromJson(Map<String, dynamic> json) {
    List<LatLng>? points = null;
    if (json['geom'] != null && json['geom']['coordinates'] != null) {
      points = [];
      final geom = json['geom'];
      final List<dynamic> coords = geom['coordinates'][0];
      for (var point in coords) {
        points.add(LatLng(point[0], point[1]));
      }
    }
    final meetingPoint = json['meeting_point'] != null ? LatLng.fromJson(json['meeting_point']) : null;
    final captains = json['captains'] != null ? Captains.fromJson(json['captains']) : null;

    return Cluster(
      id: json['id'],
      name: json['name'],
      meetingPlace: json['meeting_place'],
      notes: json['notes'],
      geom:  points ,
      meetingPoint: meetingPoint,
      captains: captains,
    );
  }

  LatLng? centroid() {
    return geom != null ? PolygonCentroid.findPolygonCentroid(geom!): null;
  }
}

class Captains extends Equatable {
  const Captains({
    this.people = const [],
  });

  final List<Person?> people;

  @override
  List<Object?> get props => [people];

  factory Captains.fromJson(Map<String, dynamic> json) {
    return Captains(
      people: json['people'] != null ? json['people'].map((person) => Person.fromJson(person)).toList() : [],
    );
  }
}
