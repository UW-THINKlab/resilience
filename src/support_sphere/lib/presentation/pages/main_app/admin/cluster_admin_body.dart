import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/logic/cubit/manage_cluster_cubit.dart';
import 'package:support_sphere/presentation/components/manage_resource_card.dart';
import 'package:support_sphere/logic/cubit/manage_resource_cubit.dart';
import 'package:support_sphere/presentation/components/resource_search_bar.dart';
import 'package:support_sphere/presentation/components/resource_type_filter.dart';
import 'package:support_sphere/presentation/pages/main_app/admin/add_household_form.dart';
import 'package:support_sphere/presentation/pages/main_app/manage_resources/add_resource_form.dart';

class ClusterAdminBody extends StatelessWidget {
  const ClusterAdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ClusterAdminBodyController();
  }
}

class ClusterAdminBodyController extends StatefulWidget {
  const ClusterAdminBodyController({super.key});

  @override
  _ClusterAdminBodyControllerState createState() =>
      _ClusterAdminBodyControllerState();
}

class _ClusterAdminBodyControllerState
    extends State<ClusterAdminBodyController> {
  bool _showingAddHousehold = false;

  @override
  Widget build(BuildContext context) {
    void switchPage() {
      setState(() {
        _showingAddHousehold = !_showingAddHousehold;
      });
    }

    return BlocProvider(
      create: (context) => ManageResourceCubit(),
      child: (_showingAddHousehold)
          ? AddHouseholdView(onPressed: switchPage)
          : ManageClusterView(addResourceOnPressed: switchPage),
    );
  }
}

class AddHouseholdView extends StatelessWidget {
  const AddHouseholdView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class ManageClusterView extends StatelessWidget {
  const ManageClusterView({super.key, this.addResourceOnPressed});

  final VoidCallback? addResourceOnPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Text(ResourceStrings.manageResources,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        _ResourcesBody(addResourceOnPressed: addResourceOnPressed),
      ],
    );
  }
}

class AddClusterView extends StatelessWidget {
  const AddClusterView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageClusterCubit, ManageClusterState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
                child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Back button
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      ResourceStrings.manageResources,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: onPressed,
                  ),

                  /// Add Cluster Form
                  Expanded(
                    child: Card(
                      child: Container(
                        margin: const EdgeInsets.all(15.0),
                        child: AddHouseholdForm(
                          onCancel: onPressed,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}

class _ResourcesBody extends StatefulWidget {
  const _ResourcesBody({this.addResourceOnPressed});

  final VoidCallback? addResourceOnPressed;

  @override
  _ResourcesBodyState createState() => _ResourcesBodyState();
}

class _ResourcesBodyState extends State<_ResourcesBody> {
  List<Resource>? _searchResults;
  String _nameQuery = '';
  String _resourceTypeQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageResourceCubit, ManageResourceState>(
      buildWhen: (previous, current) {
        _searchResults = current.resources.where((item) {
          return item.resourceType.name.contains(_resourceTypeQuery) &&
              item.name.toLowerCase().contains(_nameQuery);
        }).toList();
        return previous.resources != current.resources;
      },
      builder: (context, state) {
        // Search bar query changed
        void onQueryChanged(String query) {
          setState(() {
            _searchResults = state.resources.where((item) {
              _nameQuery = query;
              return item.name.toLowerCase().contains(_nameQuery) &&
                  item.resourceType.name.contains(_resourceTypeQuery);
            }).toList();
          });
        }

        // Filter drowndown onSelected
        void onSelected(String? value) {
          setState(() {
            if (_searchResults != null) {
              // Case to filter with search
              if (value != null && value != 'All') {
                _searchResults = state.resources.where((item) {
                  _resourceTypeQuery = value;
                  return item.resourceType.name.contains(_resourceTypeQuery) &&
                      item.name.toLowerCase().contains(_nameQuery);
                }).toList();
              } else {
                _searchResults = state.resources.where((item) {
                  return item.name.toLowerCase().contains(_nameQuery);
                }).toList();
              }
            } else {
              // Case to filter without search
              _searchResults = state.resources.where((item) {
                _resourceTypeQuery = value != 'All' ? value ?? '' : '';
                return item.resourceType.name.contains(_resourceTypeQuery);
              }).toList();
            }
          });
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: widget.addResourceOnPressed,
                    child: Text(ResourceStrings.addResource)),
                Expanded(child: ResourceSearchBar(onQueryChanged: onQueryChanged)),
                Expanded(
                    child: ResourceTypeFilter(
                  resourceTypes: state.resourceTypes,
                  onSelected: onSelected,
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _ResourceViewSection(
                      searchResults: _searchResults ?? state.resources),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ResourceViewSection extends StatelessWidget {
  final List<Resource> searchResults;

  const _ResourceViewSection({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageResourceCubit, ManageResourceState>(
      builder: (context, state) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16),
            // TODO: Add pagination at some point
            child: (searchResults.isNotEmpty)
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final resource = searchResults[index];

                      return ManageResourceCard(resource: resource);
                    },
                  )
                : Center(
                    child: Text(ResourceStrings.noResourcesFound),
                  ));
      },
    );
  }
}
