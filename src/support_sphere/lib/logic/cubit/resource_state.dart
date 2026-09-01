part of 'resource_cubit.dart';

class ResourceState extends Equatable {
  const ResourceState({
    this.resourceTypes = const [],
    this.resources = const [],
    this.userResources = const [],
    this.currentNav = ResourceNav.showAllResources,
    this.initialTabIndex = 0,
    this.selectedResource,
    this.selectionMode = false,
    this.selectedUserResourceIds = const {},
    this.searchQuery = '',
  });

  final List<ResourceTypes> resourceTypes;
  final List<Resource> resources;
  final List<UserResource> userResources;
  final ResourceNav currentNav;
  final Resource? selectedResource;
  final int initialTabIndex;
  final bool selectionMode;
  final Set<String> selectedUserResourceIds;
  final String searchQuery;

  @override
  List<Object?> get props => [
        resourceTypes,
        resources,
        userResources,
        currentNav,
        selectedResource,
        initialTabIndex,
        selectionMode,
        selectedUserResourceIds,
        searchQuery,
      ];

  ResourceState copyWith(
      {List<ResourceTypes>? resourceTypes,
      List<Resource>? resources,
      List<UserResource>? userResources,
      ResourceNav? currentNav,
      Resource? selectedResource,
      int? initialTabIndex,
      bool? selectionMode,
      Set<String>? selectedUserResourceIds,
      String? searchQuery}) {
    return ResourceState(
        resourceTypes: resourceTypes ?? this.resourceTypes,
        resources: resources ?? this.resources,
        userResources: userResources ?? this.userResources,
        currentNav: currentNav ?? this.currentNav,
        selectedResource: selectedResource ?? this.selectedResource,
        initialTabIndex: initialTabIndex ?? this.initialTabIndex,
        selectionMode: selectionMode ?? this.selectionMode,
        selectedUserResourceIds:
            selectedUserResourceIds ?? this.selectedUserResourceIds,
        searchQuery: searchQuery ?? this.searchQuery);
  }
}
