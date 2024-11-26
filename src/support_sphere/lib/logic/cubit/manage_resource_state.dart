part of 'manage_resource_cubit.dart';

class ManageResourceState extends Equatable {
  const ManageResourceState({
    this.resourceTypes = const [],
    this.resources = const [],
  });

  final List<ResourceTypes> resourceTypes;
  final List<Resource> resources;

  @override
  List<Object?> get props => [resourceTypes, resources];

  List<String> get resourcesNames {
    return resources.map((e) => e.name).toList();
  }

  ManageResourceState copyWith({
    List<ResourceTypes>? resourceTypes,
    List<Resource>? resources,
  }) {
    return ManageResourceState(
      resourceTypes: resourceTypes ?? this.resourceTypes,
      resources: resources ?? this.resources,
    );
  }
}