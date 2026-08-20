import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/person.dart' show Person;
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/user.dart';

class ManageNeighborhoodState extends Equatable {
  const ManageNeighborhoodState({
    this.clusters = const [],
    this.info = const {},
    this.admins = const [],
  });

  final List<Cluster> clusters;
  final Map<String, dynamic> info;
  final List<Person> admins;

  @override
  List<Object?> get props => [clusters, info, admins];

  ManageNeighborhoodState copyWith({
    final List<Cluster>? clusters,
    final Map<String, dynamic>? info,
    final List<Person>? admins,
  }) {
    return ManageNeighborhoodState(
      clusters: clusters ?? this.clusters,
      info: info ?? this.info,
      admins: admins ?? this.admins,
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

  void neighborhoodChanged(List<Cluster>? clusters, Map<String, Object>? info) {
    emit(state.copyWith(clusters: clusters));
  }

  void adminsChanged(List<Person> admins) {
    emit(state.copyWith(admins: admins));
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