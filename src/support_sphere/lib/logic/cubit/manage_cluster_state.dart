part of 'manage_cluster_cubit.dart';

class ManageClusterState extends Equatable {
  const ManageClusterState({
    this.households = const [],
    this.cluster,
  });

  final List<Household> households;
  final Cluster? cluster;

  @override
  List<Object?> get props => [cluster, households];

  ManageClusterState copyWith({
    final List<Household>? households,
    final Cluster? cluster,
  }) {
    return ManageClusterState(
      households: households ?? this.households,
      cluster: cluster ?? this.cluster,
    );
  }
}