import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/person.dart';

class Cluster extends Equatable {

  const Cluster({
    required this.id,
    this.name = '',
    this.meetingPlace = '',
    this.captains,
  });

  /// The current user's id, which matches the auth user id
  final String id;
  final String? name;
  final String? meetingPlace;
  final Captains? captains;

  @override
  List<Object?> get props => [id, name, meetingPlace, captains];

  copyWith({
    String? id,
    String? name,
    String? meetingPlace,
    Captains? captains,
  }) {
    return Cluster(
      id: id ?? this.id,
      name: name ?? this.name,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      captains: captains ?? this.captains,
    );
  }

  factory Cluster.fromJson(Map<String, dynamic> json) {
    return Cluster(
      id: json['id'],
      name: json['name'],
      meetingPlace: json['meeting_place'],
      captains: json['captains'] != null ? Captains.fromJson(json['captains']) : null,
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

  factory Captains.fromJson(Map<String, dynamic> json) {
    return Captains(
      people: json['people'] != null ? json['people'].map((person) => Person.fromJson(person)).toList() : [],
    );
  }
}
