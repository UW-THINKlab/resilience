part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.userProfile,
    this.household,
    this.authUser,
    this.cluster,
  });

  final Person? userProfile;
  final MyAuthUser? authUser;
  final Household? household;
  final Cluster? cluster;

  @override
  List<Object?> get props => [userProfile, authUser, household, cluster];

  ProfileState copyWith({
    Person? userProfile,
    MyAuthUser? authUser,
    Household? household,
    Cluster? cluster,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      authUser: authUser ?? this.authUser,
      household: household ?? this.household,
      cluster: cluster ?? this.cluster,
    );
  }
}
