import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/user.dart';

part 'manage_cluster_state.dart';

class ManageClusterCubit extends Cubit<ManageClusterState> {
  ManageClusterCubit() : super(const ManageClusterState()) {
    fetchCluster(); // must be first to populate
    fetchHouseholds();
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
  }

  void fetchHouseholds() async {
    List<Household> households = await _clusterRepo.getHouseholds(state.cluster!.id);
    householdsChanged(households);
  }

  void addHousehold(Household household) async {
    await _clusterRepo.addHousehold(state.cluster!.id, household);
    fetchHouseholds();
  }

  void deleteHousehold(String id) async {
    await _clusterRepo.deleteHousehold(id);
    fetchHouseholds();
  }
}