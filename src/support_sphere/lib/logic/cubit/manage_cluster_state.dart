import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/user.dart';


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

class ManageClusterCubit extends Cubit<ManageClusterState> {
  ManageClusterCubit() : super(const ManageClusterState()) {
    fetchCluster();
  }

  final ClusterRepository _clusterRepo = ClusterRepository();
  final UserRepository _userRepo = UserRepository();

  void householdsChanged(List<Household> households) {
    emit(state.copyWith(households: households));
  }

  void clusterChanged(Cluster cluster) {
    emit(state.copyWith(cluster: cluster));
  }

  void fetchCluster() async {
    Cluster? cluster = await _userRepo.getMyCluster();
    clusterChanged(cluster!);

    List<Household> households = await _clusterRepo.getHouseholds(state.cluster!.id);
    householdsChanged(households);
  }

  void addHousehold(Household household) async {
    await _clusterRepo.addHousehold(state.cluster!.id, household);
    fetchCluster();
  }

  void deleteHousehold(String id) async {
    await _clusterRepo.deleteHousehold(id);
    fetchCluster();
  }

  void upsertCluster(Map<String, dynamic> cluster) async {
    await _clusterRepo.upsertCluster(cluster);
    fetchCluster();
  }

}
