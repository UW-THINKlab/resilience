import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class HouseholdFilter extends StatefulWidget {
  HouseholdFilter(
      {super.key, this.onSelected});

  final List<String> householdFilters = ["All households", "Has resources", "Low participation"]; // FIXME stringify
  final void Function(String?)? onSelected;

  @override
  State<HouseholdFilter> createState() => _HouseholdTypeFilterState();
}

class _HouseholdTypeFilterState extends State<HouseholdFilter> {
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
    final filters = widget.householdFilters;
    //final list = (widget.includeAll) ? ['All', ...filters] : filters;
    return Container(
      padding: EdgeInsets.all(16),
      child: DropdownMenu<String>(
        width: 200,
        label: const Text(HouseholdStrings.selectFilter),
        initialSelection: filters.first,
        onSelected: widget.onSelected ?? _defaultOnSelected,
        dropdownMenuEntries:
            filters.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}
