part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.userProfile,
    this.household,
    this.authUser,
  });

  final Person? userProfile;
  final AuthUser? authUser;
  final Household? household;

  @override
  List<Object?> get props => [userProfile, authUser, household];

  ProfileState copyWith({
    Person? userProfile,
    AuthUser? authUser,
    Household? household,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      authUser: authUser ?? this.authUser,
      household: household ?? this.household,
    );
  }
}
