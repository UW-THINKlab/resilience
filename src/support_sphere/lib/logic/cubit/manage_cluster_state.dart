import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/data/repositories/cluster.dart' hide log;
import 'package:support_sphere/data/repositories/user.dart' hide log;

class ManageClusterState extends Equatable {
  const ManageClusterState({
    //this.clusterId,
    this.households = const [],
    this.members = const [],
    this.cluster,
  });

  //final String? clusterId;
  final Cluster? cluster;
  final List<Household> households;
  final List<Person> members;

  @override
  List<Object?> get props => [cluster, households, members];

  ManageClusterState copyWith({
    final List<Household>? households,
    final Cluster? cluster,
    final List<Person>? members,
  }) {
    return ManageClusterState(
      households: households ?? this.households,
      cluster: cluster ?? this.cluster,
      members: members ?? this.members,
    );
  }
}

// Notes to self, in the code, after watching BLoC and Cubit research.
// The ManageClusterState has all necessary data RE "editing" a cluster.
// This includes cluster details, captains, households and members.
// Instead of initialization, use an external call - state change.

class ManageClusterCubit extends Cubit<ManageClusterState> {
  ManageClusterCubit(String? clusterId) : super(ManageClusterState()) {
    if (clusterId != null && clusterId != "") {
      fetchClusterId(clusterId);
    } else {
      fetchMyCluster();
    }
  }

  final ClusterRepository _clusterRepo = ClusterRepository();
  final UserRepository _userRepo = UserRepository();

  void householdsChanged(List<Household> households) {
    emit(state.copyWith(households: households));
  }

  void allChanged(
      Cluster cluster, List<Household> households, List<Person> members) {
    emit(state.copyWith(
      cluster: cluster,
      households: households,
      members: members,
    ));
  }

  void membersChanged(List<Person> members) {
    emit(state.copyWith(members: members));
  }

  void clusterChanged(Cluster cluster) {
    emit(state.copyWith(cluster: cluster));
  }

  void fetchMyCluster() async {
    Cluster? cluster = await _userRepo.getMyCluster();
    fetchCluster(cluster);
  }

  void fetchClusterId(String clusterId) async {
    Cluster? cluster = await _clusterRepo.getCluster(clusterId);
    fetchCluster(cluster);
  }

  void fetchCluster(Cluster? cluster) async {
    if (cluster != null) {
      List<Household> households = await _clusterRepo.getHouseholds(cluster.id);
      List<Person> members = await _userRepo.getClusterMembers(cluster.id);
      log.fine("FOUND cluster members: $members");
      allChanged(cluster, households, members);
    }
  }

  void fetchHouseholds() async {
    List<Household> households =
        await _clusterRepo.getHouseholds(state.cluster!.id);
    householdsChanged(households);
  }

  // void fetchMembers() async {
  //   log.fine("clusterId: ${state.clusterId}, cluster: ${state.cluster}, members: ${state.members}");
  //   if (state.clusterId == "") {
  //     log.warning("Cluster state not yet initialized");
  //   }
  //   else {
  //     List<Person> members = await _userRepo.getClusterMembers(state.clusterId);
  //     membersChanged(members);
  //   }
  // }

  void addHousehold(Household household) async {
    await _clusterRepo.addHousehold(state.cluster!.id, household);
    fetchHouseholds();
  }

  void deleteHousehold(String id) async {
    await _clusterRepo.deleteHousehold(id);
    fetchHouseholds();
  }

  Future<void> upsertCluster(Map<String, dynamic> clusterData) async {
    log.fine("Updating cluster: $clusterData");
    String clusterId = clusterData['id'];
    await _clusterRepo.upsertCluster(clusterData);
    fetchClusterId(clusterId);
  }
}
