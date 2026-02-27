import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/user_role_record.dart';
import 'package:support_sphere/data/repositories/user.dart';

part 'manage_user_roles_state.dart';

class ManageUserRolesCubit extends Cubit<ManageUserRolesState> {
  ManageUserRolesCubit() : super(const ManageUserRolesState()) {
    fetchUsers();
  }

  final UserRepository _userRepository = UserRepository();

  void usersChanged(List<UserRoleRecord> users) {
    emit(state.copyWith(users: users));
  }

  Future<void> fetchUsers() async {
    final users = await _userRepository.getAllUsersWithRoles();
    usersChanged(users);
  }

  Future<void> grantSubcomAgentRole(String userProfileId) async {
    await _userRepository.grantSubcomAgentRole(userProfileId);
    await fetchUsers();
  }

  Future<void> revokeSubcomAgentRole(String userProfileId) async {
    await _userRepository.revokeSubcomAgentRole(userProfileId);
    await fetchUsers();
  }
}
