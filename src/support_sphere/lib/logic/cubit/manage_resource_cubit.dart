import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/data/repositories/resource.dart';

part 'manage_resource_state.dart';

class ManageResourceCubit extends Cubit<ManageResourceState> {
  ManageResourceCubit() : super(const ManageResourceState()) {
    fetchResourceTypes();
    fetchResources();
  }

  final ResourceRepository _resourceRepository = ResourceRepository();

  void resourceTypesChanged(List<ResourceTypes> resourceTypes) {
    emit(state.copyWith(resourceTypes: resourceTypes));
  }

  void resourcesChanged(List<Resource> resources) {
    emit(state.copyWith(resources: resources));
  }

  void fetchResourceTypes() async {
    List<ResourceTypes> resourceTypes = await _resourceRepository.getResourceTypes();
    resourceTypesChanged(resourceTypes);
  }

  void fetchResources() async {
    List<Resource> resources = await _resourceRepository.getResources();
    resourcesChanged(resources);
  }

  void addNewResource(Resource resource) async {
    await _resourceRepository.addNewResource(resource);
    fetchResources();
  }

  void deleteResource(String id) async {
    await _resourceRepository.deleteResource(id);
    fetchResources();
  }
}