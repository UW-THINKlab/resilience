import 'package:equatable/equatable.dart';
import 'package:uuid/v4.dart';

/// {@template user}
/// AuthUser model
///
/// [AuthUser.empty] represents an unauthenticated user.
/// [AuthUser.sample] represents an unauthenticated user with a given email and id
/// {@endtemplate}
class AuthUser extends Equatable {
  /// {@macro user}
  const AuthUser({
    required this.uuid,
    this.email,
    this.phone,
  });

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String uuid;

  /// The current user's name (display name).
  final String? phone;

  /// Empty user which represents an unauthenticated user.
  static const empty = AuthUser(uuid: '');

  /// Sample user which represents a user with a given email and id
  /// for testing purposes.
  /// This user is not authenticated.
  static final sample = AuthUser(
    uuid: const UuidV4().generate(),
    phone: '+15552345678',
    email: 'johndoe@example.com'
  );

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == AuthUser.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != AuthUser.empty;

  @override
  List<Object?> get props => [email, uuid, phone];
}
