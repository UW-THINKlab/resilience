import 'package:equatable/equatable.dart';

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

class Profile extends Equatable {

  const Profile({
    required this.id,
    required this.userName,
  });

  /// The current user's id, which matches the auth user id
  final String id;

  /// The current user's username.
  final String userName;

  @override
  List<Object?> get props => [id, userName];
}
