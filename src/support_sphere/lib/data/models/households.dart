import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:support_sphere/data/models/person.dart';

class Household extends Equatable {

  const Household({
    required this.id,
    required this.clusterId,
    this.name = '',
    this.address = '',
    this.notes = '',
    this.pets = '',
    this.accessibilityNeeds = '',
    this.houseHoldMembers,
    this.geom,
  });

  /// The current user's id, which matches the auth user id
  final String id;
  final String clusterId;
  final String? name;
  final String? address;
  final String? notes;
  final String? pets;
  final String? accessibilityNeeds;
  final HouseHoldMembers? houseHoldMembers;
  final LatLng? geom;


  @override
  List<Object?> get props => [id, name, address, notes, pets, accessibilityNeeds, houseHoldMembers, clusterId];

  Household copyWith({
    String? id,
    String? name,
    String? address,
    String? notes,
    String? pets,
    String? accessibilityNeeds,
    HouseHoldMembers? houseHoldMembers,
    String? clusterId,
    LatLng? geom,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      pets: pets ?? this.pets,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      houseHoldMembers: houseHoldMembers ?? this.houseHoldMembers,
      clusterId: clusterId ?? this.clusterId,
      geom: geom ?? this.geom,
    );
  }

  factory Household.fromJson(Map<String, dynamic> json) {
    // {type: Point, coordinates: [47.6501785, -122.2767234]}
    LatLng? point;
    if (json['geom'] != null) {
      point = LatLng(json['geom']['coordinates'][0], json['geom']['coordinates'][1]);
    }

    return Household(
      id: json['id'],
      clusterId: json['cluster_id'],
      name: json['name'],
      address: json['address'],
      notes: json['notes'],
      pets: json['pets'],
      accessibilityNeeds: json['accessibility_needs'],
      geom: point,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'notes': notes,
      'pets': pets,
      'accessibilityNeeds': accessibilityNeeds,
      'houseHoldMembers': houseHoldMembers,
      'clusterId': clusterId,
      'geom': geom,
    };
  }
}

class HouseHoldMembers extends Equatable {
  const HouseHoldMembers({
    this.members = const [],
  });

  final List<Person?> members;

  @override
  List<Object?> get props => [members];
}
