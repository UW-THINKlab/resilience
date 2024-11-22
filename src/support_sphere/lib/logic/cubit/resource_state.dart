part of 'resource_cubit.dart';

class ResourceState extends Equatable {
  const ResourceState({
    this.resourceTypes = const [],
    this.resources = const [],
    this.userResources = const [],
    this.currentNav = ResourceNav.showAllResources,
    this.initialTabIndex = 0,
    this.selectedResource,
  });

  final List<ResourceTypes> resourceTypes;
  final List<Resource> resources;
  final List<UserResource> userResources;
  final ResourceNav currentNav;
  final Resource? selectedResource;
  final int initialTabIndex;

  @override
  List<Object?> get props => [
        resourceTypes,
        resources,
        userResources,
        currentNav,
        selectedResource,
        initialTabIndex
      ];

  ResourceState copyWith(
      {List<ResourceTypes>? resourceTypes,
      List<Resource>? resources,
      List<UserResource>? userResources,
      ResourceNav? currentNav,
      Resource? selectedResource,
      int? initialTabIndex}) {
    return ResourceState(
        resourceTypes: resourceTypes ?? this.resourceTypes,
        resources: resources ?? this.resources,
        userResources: userResources ?? this.userResources,
        currentNav: currentNav ?? this.currentNav,
        selectedResource: selectedResource ?? this.selectedResource,
        initialTabIndex: initialTabIndex ?? this.initialTabIndex);
  }
}
