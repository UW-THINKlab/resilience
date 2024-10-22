import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/person.dart';

class Cluster extends Equatable {

  const Cluster({
    required this.id,
    this.name = '',
    this.meeting_place = '',
    this.captains = null,
  });

  /// The current user's id, which matches the auth user id
  final String id;
  final String? name;
  final String? meeting_place;
  final Captains? captains;

  @override
  List<Object?> get props => [id, name, meeting_place, captains];

  copyWith({
    String? id,
    String? name,
    String? meeting_place,
    Captains? captains,
  }) {
    return Cluster(
      id: id ?? this.id,
      name: name ?? this.name,
      meeting_place: meeting_place ?? this.meeting_place,
      captains: captains ?? this.captains,
    );
  }
}

class Captains extends Equatable {
  const Captains({
    this.people = const [],
  });

  final List<Person?> people;

  @override
  List<Object?> get props => [people];
}
