import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/resource.dart';
import 'package:support_sphere/data/models/resource_types.dart';
import 'package:support_sphere/presentation/components/resource_card.dart';
import 'package:support_sphere/logic/cubit/manage_resource_cubit.dart';

class ManageResourcesBody extends StatelessWidget {
  const ManageResourcesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageResourceCubit(),
      child: const Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: const Center(
              // TODO: Add profile picture
              child: Text('Manage Resources',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          _ResourcesBody(),
        ],
      ),
    );
  }
}

class _ResourcesBody extends StatefulWidget {
  const _ResourcesBody({super.key});

  @override
  _ResourcesBodyState createState() => _ResourcesBodyState();
}

class _ResourcesBodyState extends State<_ResourcesBody> {
  List<Resource>? _searchResults = null;
  String _nameQuery = '';
  String _resourceTypeQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageResourceCubit, ManageResourceState>(
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
                    onPressed: null, child: Text("Add new resource")),
                Expanded(child: _SearchBar(onQueryChanged: onQueryChanged)),
                Expanded(
                    child: _ResourceTypeFilter(
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

class _SearchBar extends StatefulWidget {
  final void Function(String)? onQueryChanged;

  const _SearchBar({Key? key, this.onQueryChanged}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  String query = '';

  void _defaultOnQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        onChanged: widget.onQueryChanged ?? _defaultOnQueryChanged,
        decoration: InputDecoration(
          labelText: ResourceStrings.searchResources,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

class _ResourceTypeFilter extends StatefulWidget {
  const _ResourceTypeFilter(
      {super.key, required this.resourceTypes, this.onSelected});

  final List<ResourceTypes> resourceTypes;
  final void Function(String?)? onSelected;

  @override
  State<_ResourceTypeFilter> createState() => _ResourceTypeFilterState();
}

class _ResourceTypeFilterState extends State<_ResourceTypeFilter> {
  String dropdownValue = '';

  void _defaultOnSelected(String? value) {
    setState(() {
      // This is called when the user selects an item.
      setState(() {
        dropdownValue = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ['All'] + widget.resourceTypes.map((e) => e.name).toList();
    return Container(
      padding: EdgeInsets.all(16),
      child: DropdownMenu<String>(
        width: 200,
        label: const Text('Select a resource type'),
        initialSelection: list.first,
        onSelected: widget.onSelected ?? _defaultOnSelected,
        dropdownMenuEntries:
            list.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}

class _ResourceViewSection extends StatelessWidget {
  final List<Resource> searchResults;

  const _ResourceViewSection({Key? key, required this.searchResults})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageResourceCubit, ManageResourceState>(
      builder: (context, state) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16),
            // TODO: Add pagination at some point
            child: (searchResults.length > 0)
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final resource = searchResults[index];

                      return ResourceCard(resource: resource);
                    },
                  )
                : Center(
                    child: Text(ResourceStrings.noResourcesFound),
                  ));
      },
    );
  }
}
