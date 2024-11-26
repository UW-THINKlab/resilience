import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/resource_types.dart';

class ResourceTypeFilter extends StatefulWidget {
  const ResourceTypeFilter(
      {super.key, required this.resourceTypes, this.onSelected, this.includeAll = true});

  final List<ResourceTypes> resourceTypes;
  final void Function(String?)? onSelected;
  final bool includeAll;

  @override
  State<ResourceTypeFilter> createState() => _ResourceTypeFilterState();
}

class _ResourceTypeFilterState extends State<ResourceTypeFilter> {
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
    final resourceTypesStrings = widget.resourceTypes.map((e) => e.name).toList();
    final list = (widget.includeAll) ? ['All', ...resourceTypesStrings] : resourceTypesStrings;
    return Container(
      padding: EdgeInsets.all(16),
      child: DropdownMenu<String>(
        width: 200,
        label: const Text(ResourceStrings.selectResourceType),
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
