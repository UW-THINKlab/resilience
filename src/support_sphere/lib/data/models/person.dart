import 'package:equatable/equatable.dart';

/// A class representing a person.
/// A person is an entity that describes a real life person's details
/// such as their [nickname], [givenName], [familyName], whether they are [isSafe],
/// and whether they [needsHelp].
/// If this person has a [profile], it means that they have a login account
/// and their profile details are stored in the database.
class Person extends Equatable {
  const Person({
    this.nickname,
    required this.id,
    this.profile,
    this.givenName = '',
    this.familyName = '',
    this.isSafe = true,
    this.needsHelp = true,
  });

  /// The current user's id.
  /// This is a unique identifier for the user as reflected in the database.
  final String id;

  /// The current user's profile.
  /// This is optional and may be null.
  final Profile? profile;
  
  /// The current user's given name.
  final String givenName;

  /// The current user's family name.
  final String familyName;

  /// The current user's nickname.
  final String? nickname;

  /// The current user's safety status.
  final bool isSafe;

  /// The current user's help status.
  final bool needsHelp;

  @override
  List<Object?> get props => [
        id,
        profile,
        givenName,
        familyName,
        nickname,
        isSafe,
        needsHelp,
      ];
}


/// A class representing a user's profile.
/// A profile is an entity that describes a user's details such as their [id]
/// which is the same as their auth user id.
/// A profile is associated with a person that describes the user's real life details.
/// The profile is use for user app purposes.
class Profile extends Equatable {

  const Profile({
    required this.id,
  });

  /// The current user's id, which matches the auth user id
  final String id;

  @override
  List<Object?> get props => [id];
}
