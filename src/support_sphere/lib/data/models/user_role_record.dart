import 'package:equatable/equatable.dart';

/// A class representing a user's role record.
/// This combines the user profile info with their assigned role.
class UserRoleRecord extends Equatable {
  const UserRoleRecord({
    required this.userProfileId,
    required this.givenName,
    required this.familyName,
    required this.role,
    this.userRoleId,
  });

  /// The user profile id (matches auth user id).
  final String userProfileId;

  /// The user's given name.
  final String givenName;

  /// The user's family name.
  final String familyName;

  /// The user's current role (e.g. 'USER', 'SUBCOM_AGENT', 'COM_ADMIN', 'ADMIN').
  final String role;

  /// The id of the user_roles table row (may be null if no role row exists).
  final String? userRoleId;

  String get fullName => '$givenName $familyName'.trim();

  /// Returns the display name for this user.
  /// Falls back to the user profile id if no name is available.
  String get displayName => fullName.isNotEmpty ? fullName : userProfileId;

  @override
  List<Object?> get props => [userProfileId, givenName, familyName, role, userRoleId];

  UserRoleRecord copyWith({
    String? userProfileId,
    String? givenName,
    String? familyName,
    String? role,
    String? userRoleId,
  }) {
    return UserRoleRecord(
      userProfileId: userProfileId ?? this.userProfileId,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      role: role ?? this.role,
      userRoleId: userRoleId ?? this.userRoleId,
    );
  }
}
