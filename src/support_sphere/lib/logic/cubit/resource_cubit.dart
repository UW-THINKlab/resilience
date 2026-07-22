import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_request.dart';
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
    List<ResourceTypes> resourceTypes =
        await _resourceRepository.getResourceTypes();
    resourceTypesChanged(resourceTypes);
  }

  void fetchResources() async {
    List<Resource> resources = await _resourceRepository.getResources();
    resourcesChanged(resources);
  }

  void fetchUserResources(String userId) async {
    List<UserResource> userResources =
        await _resourceRepository.getUserResourcesByUserId(userId);
    emit(state.copyWith(userResources: userResources));
  }

  void addToUserInventory(Map<String, dynamic> data) async {
    final userId = authUser.uuid;
    final payload = {...data, 'user_id': userId};
    await _resourceRepository.addToUserInventory(payload);
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  Future<void> deleteUserResource(String id) async {
    await _resourceRepository.notifyReservationsRemoved([id]);
    await _resourceRepository.deleteUserResource(id);
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  Future<void> updateUserResource({
    required String id,
    required int quantity,
    String? notes,
    required SHARING_SCOPES sharingScope,
    required SHARING_SCOPES sharingScopeEmergency,
  }) async {
    await _resourceRepository.updateUserResource(
      id: id,
      quantity: quantity,
      notes: notes,
      sharingScope: sharingScope,
      sharingScopeEmergency: sharingScopeEmergency,
    );
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  Future<void> bulkUpdateUserResources(
      List<
              ({
                String id,
                int quantity,
                String? notes,
                SHARING_SCOPES sharingScope,
                SHARING_SCOPES sharingScopeEmergency
              })>
          edits) async {
    for (final edit in edits) {
      await _resourceRepository.updateUserResource(
        id: edit.id,
        quantity: edit.quantity,
        notes: edit.notes,
        sharingScope: edit.sharingScope,
        sharingScopeEmergency: edit.sharingScopeEmergency,
      );
    }
    emit(state.copyWith(selectionMode: false, selectedUserResourceIds: {}));
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  void enterSelectionModeAndSelect(String id) {
    emit(state.copyWith(
      selectionMode: true,
      selectedUserResourceIds: {id},
    ));
  }

  void toggleSelectionMode() {
    if (state.selectionMode) {
      emit(state.copyWith(selectionMode: false, selectedUserResourceIds: {}));
    } else {
      emit(state.copyWith(selectionMode: true));
    }
  }

  void toggleUserResourceSelected(String id) {
    final current = Set<String>.from(state.selectedUserResourceIds);
    if (!current.remove(id)) current.add(id);
    emit(state.copyWith(selectedUserResourceIds: current));
  }

  void setSelectedUserResourceIds(Set<String> ids) {
    emit(state.copyWith(selectedUserResourceIds: ids));
  }

  void searchQueryChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> deleteSelected() async {
    final ids = state.selectedUserResourceIds.toList();
    await _resourceRepository.notifyReservationsRemoved(ids);
    await Future.wait(ids.map(_resourceRepository.deleteUserResource));
    emit(state.copyWith(selectionMode: false, selectedUserResourceIds: {}));
    fetchUserResources(authUser.uuid);
    fetchResources();
  }

  Future<List<String>> getUserResourceIdsWithReservations(List<String> ids) {
    return _resourceRepository.getUserResourceIdsWithReservations(ids);
  }

  Future<void> submitResourceRequest({
    required Map<String, dynamic> requestData,
    required Future<bool> Function(SuggestedResourceRequest) confirmation,
    required bool isEmergency,
    required Future<bool> Function(int totalAvailable, int requested)
        onInsufficientInventory,
    required DateTime expiresAt,
  }) async {
    if (isClosed) return;
    final ResourceRequest resourceRequest = ResourceRequest(
      resourceId: requestData['resource_id'],
      resourceName: requestData['resource_name'],
      resourceTypeName: requestData['resource_type_name'],
      quantity: requestData['quantity'],
      requestScope: requestData['request_scope'],
      notes: requestData['notes'],
      lon: requestData['current_longitude'],
      lat: requestData['current_latitude'],
      expiresAt: expiresAt,
    );
    await _resourceRepository.submitResourceRequestAndNotify(
      resourceRequest: resourceRequest,
      requesterProfileId: authUser.uuid,
      confirmation: confirmation,
      isEmergency: isEmergency,
      onInsufficientInventory: onInsufficientInventory,
    );
  }
}
