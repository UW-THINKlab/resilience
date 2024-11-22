import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:support_sphere/data/enums/resource_nav.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/data/models/user_resource.dart';
import 'package:support_sphere/data/repositories/resource.dart';

part 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  ResourceCubit() : super(const ResourceState()) {
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
    print("fetching resources");
    List<Resource> resources = await _resourceRepository.getResources();
    resourcesChanged(resources);
  }
}