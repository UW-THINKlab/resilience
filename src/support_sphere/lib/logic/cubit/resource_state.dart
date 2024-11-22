part of 'resource_cubit.dart';

class ResourceState extends Equatable {
  const ResourceState({
    this.resourceTypes = const [],
    this.resources = const [],
    this.userResources = const [],
  });

  final List<ResourceTypes> resourceTypes;
  final List<Resource> resources;
  final List<UserResource> userResources;

  @override
  List<Object?> get props => [resourceTypes, resources, userResources];

  ResourceState copyWith({
    List<ResourceTypes>? resourceTypes,
    List<Resource>? resources,
    List<UserResource>? userResources,
  }) {
    return ResourceState(
      resourceTypes: resourceTypes ?? this.resourceTypes,
      resources: resources ?? this.resources,
      userResources: userResources ?? this.userResources,
    );
  }
}