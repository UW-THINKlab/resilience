import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/repositories/cluster.dart';

part 'manage_neighborhood_state.dart';

class ManageNeighborhoodCubit extends Cubit<ManageNeighborhoodState> {
  ManageNeighborhoodCubit() : super(const ManageNeighborhoodState()) {
    fetchNeighborhood();
  }

  final ClusterRepository _clusterRepo = ClusterRepository();

  void neighborhoodChanged(List<Cluster> clusters) {
    emit(state.copyWith(clusters: clusters));
  }

  void fetchNeighborhood() async {
    final clusters = await _clusterRepo.getAllClusters();
    neighborhoodChanged(clusters);
  }

  void addCluster(Cluster cluster) async {
    await _clusterRepo.addCluster(cluster);
    fetchNeighborhood();
  }

  void deleteCluster(String clusterId) async {
    await _clusterRepo.deleteCluster(clusterId);
    fetchNeighborhood();
  }
}