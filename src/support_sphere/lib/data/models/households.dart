import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/person.dart';

class Household extends Equatable {

  const Household({
    required this.id,
    required this.cluster_id,
    this.name = '',
    this.address = '',
    this.notes = '',
    this.pets = '',
    this.accessibility_needs = '',
    this.houseHoldMembers = null,
  });

  /// The current user's id, which matches the auth user id
  final String id;
  final String cluster_id;
  final String? name;
  final String? address;
  final String? notes;
  final String? pets;
  final String? accessibility_needs;
  final HouseHoldMembers? houseHoldMembers;

  @override
  List<Object?> get props => [id, name, address, notes, pets, accessibility_needs, houseHoldMembers, cluster_id];

  copyWith({
    String? id,
    String? name,
    String? address,
    String? notes,
    String? pets,
    String? accessibility_needs,
    HouseHoldMembers? houseHoldMembers,
    String? cluster_id,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      pets: pets ?? this.pets,
      accessibility_needs: accessibility_needs ?? this.accessibility_needs,
      houseHoldMembers: houseHoldMembers ?? this.houseHoldMembers,
      cluster_id: cluster_id ?? this.cluster_id,
    );
  }

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      notes: json['notes'],
      pets: json['pets'],
      accessibility_needs: json['accessibility_needs'],
      cluster_id: json['cluster_id'],
    );
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
