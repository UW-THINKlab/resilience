part of 'manage_users_cubit.dart';

class ManageUsersState extends Equatable {
  const ManageUsersState({
    this.clusterUsers = const [],
  });

  final List<ClusterUser> clusterUsers;

  @override
  List<Object?> get props => [clusterUsers];

  ManageUsersState copyWith({
    List<ClusterUser>? clusterUsers,
  }) {
    return ManageUsersState(
      clusterUsers: clusterUsers ?? this.clusterUsers,
    );
  }
}
