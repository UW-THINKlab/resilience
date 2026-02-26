import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/repositories/user.dart';

part 'manage_users_state.dart';

class ManageUsersCubit extends Cubit<ManageUsersState> {
  ManageUsersCubit(this.clusterId) : super(const ManageUsersState()) {
    fetchClusterUsers();
  }

  final String clusterId;
  final UserRepository _userRepository = UserRepository();

  void clusterUsersChanged(List<ClusterUser> clusterUsers) {
    emit(state.copyWith(clusterUsers: clusterUsers));
  }

  Future<void> fetchClusterUsers() async {
    final clusterUsers = await _userRepository.getClusterUsersWithCaptainStatus(
      clusterId: clusterId,
    );
    clusterUsersChanged(clusterUsers);
  }

  Future<void> grantCaptain(String userProfileId) async {
    await _userRepository.grantClusterCaptain(
      userProfileId: userProfileId,
      clusterId: clusterId,
    );
    await fetchClusterUsers();
  }

  Future<void> revokeCaptain(String userProfileId) async {
    await _userRepository.revokeClusterCaptain(
      userProfileId: userProfileId,
      clusterId: clusterId,
    );
    await fetchClusterUsers();
  }
}
