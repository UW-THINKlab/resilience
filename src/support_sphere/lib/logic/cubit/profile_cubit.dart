import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/households.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:support_sphere/data/repositories/user.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.authUser) : super(const ProfileState()) {
    authUserChanged(authUser);
    fetchProfile();
  }

  final AuthUser authUser;
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final UserRepository _userRepository = UserRepository();

  void profileChanged(Person? userProfile) {
    emit(state.copyWith(userProfile: userProfile));
  }

  void authUserChanged(AuthUser? authUser) {
    emit(state.copyWith(authUser: authUser));
  }

  void householdChanged(Household? household) {
    emit(state.copyWith(household: household));
  }

  void clusterChanged(Cluster? cluster) {
    emit(state.copyWith(cluster: cluster));
  }

  Future<void> fetchProfile() async {
    try {
      /// Get the user profile by user id
      final Person? userProfile = await _userRepository.getPersonProfileByUserId(
        userId: authUser.uuid,
      );
      profileChanged(userProfile);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      /// Get the household of the user profile
      Household? household = await _userRepository.getHouseholdByPersonId(
        userProfile.id,
      );
      if (household != null) {
        /// Get the household members of the household
        final HouseHoldMembers? houseHoldMembers = await _userRepository.getHouseholdMembersByHouseholdId(household.id);

        if (houseHoldMembers != null) {
          household = household.copyWith(houseHoldMembers: houseHoldMembers);
        }
        householdChanged(household);
      } else {
        throw Exception('Household not found');
      }

      /// Get the cluster and its captains information
      // ignore: unnecessary_null_comparison
      Cluster? cluster = household == null
        ? null
        : await _userRepository.getClusterById(clusterId: household.cluster_id);

      if (cluster != null) {
        /// Get the captains of the cluster
        final Captains? captains = await _userRepository.getCaptainsByClusterId(clusterId: cluster.id);

        if (captains != null) {
          cluster = cluster.copyWith(captains: captains);
        }
        clusterChanged(cluster);
      } else {
        throw Exception('Cluster not found');
      }
    } catch (_) {
      /// TODO: Handle error if there are no user profile or household for some reason
      profileChanged(null);
      householdChanged(null);
      clusterChanged(null);
    }
  }

  Future<void> savePersonalInfoModal({
    required String personId,
    String? givenName,
    String? familyName,
    String? phone,
  }) async {
    try {
      await _userRepository.updateUserName(
        personId: personId,
        givenName: givenName,
        familyName: familyName,
      );
      AuthUser updatedAuthUser = await _authRepository.updateUserPhoneNumber(
        phone: phone,
      );
      authUserChanged(updatedAuthUser);
      // TODO: Consider optimizing this to perform a partial update from the API result instead of fetching the entire profile
      await fetchProfile();
    } catch (error) {
      // TODO: Handle error
    }
  }

  Future<void> saveHouseholdInfoModal({
    required String householdId,
    String? address,
    String? pets,
    String? accessibilityNeeds,
    String? notes,
  }) async {
    try {
      await _userRepository.updateHousehold(
        householdId: householdId,
        address: address,
        pets: pets,
        accessibilityNeeds: accessibilityNeeds,
        notes: notes,
      );
      // TODO: Consider optimizing this to perform a partial update from the API result instead of fetching the entire profile
      await fetchProfile();
    } catch (error) {
      // TODO: Handle error
    }
  }
}
