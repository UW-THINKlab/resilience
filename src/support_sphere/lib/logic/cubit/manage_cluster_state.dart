import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/data/repositories/cluster.dart' hide log;
import 'package:support_sphere/data/repositories/user.dart' hide log;


class ManageClusterState extends Equatable {
  const ManageClusterState({
    required this.clusterId,
    this.households = const [],
    this.members = const [],
    this.cluster = null,
  });

  final String clusterId;
  final Cluster? cluster;
  final List<Household> households;
  final List<Person> members;

  @override
  List<Object?> get props => [clusterId, cluster, households, members];

  ManageClusterState copyWith({
    final List<Household>? households,
    final Cluster? cluster,
    final List<Person>? members,
  }) {
    return ManageClusterState(
      clusterId: this.clusterId,
      households: households ?? this.households,
      cluster: cluster ?? this.cluster,
      members: members ?? this.members,
    );
  }
}

class ManageClusterCubit extends Cubit<ManageClusterState> {
  ManageClusterCubit(String clusterId) : super(ManageClusterState(clusterId: clusterId)) {
    fetchCluster();
    fetchHouseholds();
    fetchMembers();
  }

  final ClusterRepository _clusterRepo = ClusterRepository();
  final UserRepository _userRepo = UserRepository();

  void householdsChanged(List<Household> households) {
    emit(state.copyWith(households: households));
  }

  void clusterChanged(Cluster cluster) {
    emit(state.copyWith(cluster: cluster));
  }

  void membersChanged(List<Person> members) {
    emit(state.copyWith(members: members));
  }

  void fetchCluster() async {
    var clusterId = state.clusterId;
    if (clusterId == "") {
      log.warning("Cluster not initialized. Using user's cluster.");
      var cluster = await _userRepo.getMyCluster();
      if (cluster != null) {
        clusterId = cluster.id;
      }
    }

    Cluster? cluster = await _clusterRepo.getCluster(clusterId);
    clusterChanged(cluster!);
  }

  void fetchHouseholds() async {
    List<Household> households = await _clusterRepo.getHouseholds(state.clusterId);
    householdsChanged(households);
  }

  void fetchMembers() async {
    List<Person> members = await _userRepo.getClusterMembers(state.clusterId);
    membersChanged(members);
  }

  void addHousehold(Household household) async {
    await _clusterRepo.addHousehold(state.clusterId, household);
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

  Future<List<Person>> getClusterMembers(String clusterId) async {
    return await _userRepo.getClusterMembers(clusterId);
  }
}
