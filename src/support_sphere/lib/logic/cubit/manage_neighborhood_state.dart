import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/repositories/cluster.dart';

class ManageNeighborhoodState extends Equatable {
  const ManageNeighborhoodState({
    this.clusters = const [],
    this.info = const {},
  });

  final List<Cluster> clusters;
  final Map<String, dynamic> info;

  @override
  List<Object?> get props => [clusters, info];

  ManageNeighborhoodState copyWith({
    final List<Cluster>? clusters,
    final Map<String, dynamic>? info,
  }) {
    return ManageNeighborhoodState(
      clusters: clusters ?? this.clusters,
      info: info ?? this.info,
    );
  }
}

class ManageNeighborhoodCubit extends Cubit<ManageNeighborhoodState> {
  ManageNeighborhoodCubit() : super(const ManageNeighborhoodState()) {
    fetchNeighborhood();
  }

  final ClusterRepository _clusterRepo = ClusterRepository();

  void neighborhoodChanged(List<Cluster>? clusters, Map<String, Object>? info) {
    emit(state.copyWith(clusters: clusters));
  }

  void fetchNeighborhood() async {
    final clusters = await _clusterRepo.getAllClusters();
    // FIXME: What neighborlood level details to LEAP admins want to see?
    final info = {
      'Total population': 3043, // QUERY: number of people
      '# Clusters': 98, // QUERY: number of clusters
      '# Households': 1021, // QUERY: number of households
      '# Resources': 2821, // QUERY: size of user-resources
    };
    neighborhoodChanged(clusters, info);
  }

  void upsertCluster(Map<String, dynamic> cluster) async {
    await _clusterRepo.upsertCluster(cluster);
    fetchNeighborhood();
  }

  void deleteCluster(String clusterId) async {
    await _clusterRepo.deleteCluster(clusterId);
    fetchNeighborhood();
  }
}