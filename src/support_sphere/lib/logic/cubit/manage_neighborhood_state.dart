part of 'manage_neighborhood_cubit.dart';

class ManageNeighborhoodState extends Equatable {
  const ManageNeighborhoodState({
    this.clusters = const [],
  });

  final List<Cluster> clusters;

  @override
  List<Object?> get props => [clusters];

  ManageNeighborhoodState copyWith({
    final List<Cluster>? clusters,
  }) {
    return ManageNeighborhoodState(
      clusters: clusters ?? this.clusters,
    );
  }
}
