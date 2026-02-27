part of 'manage_user_roles_cubit.dart';

class ManageUserRolesState extends Equatable {
  const ManageUserRolesState({
    this.users = const [],
  });

  final List<UserRoleRecord> users;

  @override
  List<Object?> get props => [users];

  ManageUserRolesState copyWith({
    List<UserRoleRecord>? users,
  }) {
    return ManageUserRolesState(
      users: users ?? this.users,
    );
  }
}
