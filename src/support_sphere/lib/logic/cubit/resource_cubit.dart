import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/data/models/user_resource.dart';
import 'package:support_sphere/data/repositories/resource.dart';

part 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  ResourceCubit(this.authUser) : super(const ResourceState()) {
    fetchResourceTypes();
    fetchResources();
    fetchUserResources(authUser.uuid);
  }

  final MyAuthUser authUser;

  final ResourceRepository _resourceRepository = ResourceRepository();

  void resourceTypesChanged(List<ResourceTypes> resourceTypes) {
    emit(state.copyWith(resourceTypes: resourceTypes));
  }

  void resourcesChanged(List<Resource> resources) {
    emit(state.copyWith(resources: resources));
  }

  void selectedResourceChanged(Resource? resource) {
    emit(state.copyWith(selectedResource: resource));
  }

  void currentNavChanged(ResourceNav nav) {
    emit(state.copyWith(currentNav: nav));
  }

  void initialTabIndexChanged(int index) {
    emit(state.copyWith(initialTabIndex: index));
  }

  void fetchResourceTypes() async {
    List<ResourceTypes> resourceTypes = await _resourceRepository.getResourceTypes();
    resourceTypesChanged(resourceTypes);
  }

  void fetchResources() async {
    List<Resource> resources = await _resourceRepository.getResources();
    resourcesChanged(resources);
  }

  void fetchUserResources(String userId) async {
    List<UserResource> userResources = await _resourceRepository.getUserResourcesByUserId(userId);
    emit(state.copyWith(userResources: userResources));
  }

  void addToUserInventory(Map<String, dynamic> data) async {
    final userId = authUser.uuid;
    final payload = {...data, 'user_id': userId};
    await _resourceRepository.addToUserInventory(payload);
    // Empty the resources list to force a refresh
    emit(state.copyWith(resources: []));
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  void deleteUserResource(String id) async {
    await _resourceRepository.deleteUserResource(id);
    // Empty the resources list to force a refresh
    emit(state.copyWith(resources: []));
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  void markUpToDateNow(String id) async {
    await _resourceRepository.markUpToDate(id, DateTime.now());
    fetchUserResources(authUser.uuid);
  }
}