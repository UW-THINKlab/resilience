import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/person.dart';

class Household extends Equatable {

  const Household({
    required this.id,
    this.name = '',
    this.address = '',
    this.notes = '',
    this.pets = '',
    this.accessibility_needs = '',
    this.houseHoldMembers = null,
  });

  /// The current user's id, which matches the auth user id
  final String id;
  final String? name;
  final String? address;
  final String? notes;
  final String? pets;
  final String? accessibility_needs;
  final HouseHoldMembers? houseHoldMembers;

  @override
  List<Object?> get props => [id, name, address, notes, pets, accessibility_needs, houseHoldMembers];

  copyWith({
    String? id,
    String? name,
    String? address,
    String? notes,
    String? pets,
    String? accessibility_needs,
    HouseHoldMembers? houseHoldMembers,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      pets: pets ?? this.pets,
      accessibility_needs: accessibility_needs ?? this.accessibility_needs,
      houseHoldMembers: houseHoldMembers ?? this.houseHoldMembers,
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
