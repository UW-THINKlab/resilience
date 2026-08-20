import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/user.dart';

class ManageNeighborhoodState extends Equatable {
  const ManageNeighborhoodState({
    this.clusters = const [],
    this.admins = const [],
    this.householdCount = 0,
    this.clustersWithoutCaptainsCount = 0,
  });

  final List<Cluster> clusters;
  final List<Person> admins;
  final int householdCount;
  final int clustersWithoutCaptainsCount;

  @override
  List<Object?> get props =>
      [clusters, admins, householdCount, clustersWithoutCaptainsCount];

  ManageNeighborhoodState copyWith({
    final List<Cluster>? clusters,
    final List<Person>? admins,
    final int? householdCount,
    final int? clustersWithoutCaptainsCount,
  }) {
    return ManageNeighborhoodState(
      clusters: clusters ?? this.clusters,
      admins: admins ?? this.admins,
      householdCount: householdCount ?? this.householdCount,
      clustersWithoutCaptainsCount:
          clustersWithoutCaptainsCount ?? this.clustersWithoutCaptainsCount,
    );
  }
}

class ManageNeighborhoodCubit extends Cubit<ManageNeighborhoodState> {
  ManageNeighborhoodCubit() : super(const ManageNeighborhoodState()) {
    fetchNeighborhood();
    fetchAdmins();
  }

  final ClusterRepository _clusterRepo = ClusterRepository();
  final UserRepository _userRepo = UserRepository();

  void neighborhoodChanged(List<Cluster> clusters, int householdCount,
      int clustersWithoutCaptainsCount) {
    emit(state.copyWith(
      clusters: clusters,
      householdCount: householdCount,
      clustersWithoutCaptainsCount: clustersWithoutCaptainsCount,
    ));
  }

  void adminsChanged(List<Person> admins) {
    emit(state.copyWith(admins: admins));
  }

  void fetchNeighborhood() async {
    // Start all three queries concurrently instead of awaiting them one at a
    // time, since only the final count computation actually depends on both
    // the cluster list and the captain-id set.
    final clustersFuture = _clusterRepo.getAllClusters();
    final householdCountFuture = _clusterRepo.getHouseholdCount();
    final clusterIdsWithCaptainsFuture = _clusterRepo.getClusterIdsWithCaptains();

    final clusters = await clustersFuture;
    final householdCount = await householdCountFuture;
    final clusterIdsWithCaptains = await clusterIdsWithCaptainsFuture;

    final clustersWithoutCaptainsCount = clusters
        .where((c) => !clusterIdsWithCaptains.contains(c.id))
        .length;
    neighborhoodChanged(clusters, householdCount, clustersWithoutCaptainsCount);
  }

  void fetchAdmins() async {
    final adminIds = await _clusterRepo.getCommunityAdminProfileIds();
    final membersMap = await _userRepo.getAllMembers();
    adminsChanged(
        adminIds.map((id) => membersMap[id]).whereType<Person>().toList());
  }

  Future<void> upsertCluster(Map<String, dynamic> cluster) async {
    await _clusterRepo.upsertCluster(cluster);
    fetchNeighborhood();
  }

  void deleteCluster(String clusterId) async {
    await _clusterRepo.deleteCluster(clusterId);
    fetchNeighborhood();
  }

  Future<void> upsertNeighborhoodAdmins(List<Person> admins) async {
    await _clusterRepo.updateCommunityAdmins(admins);
    fetchAdmins();
  }
}