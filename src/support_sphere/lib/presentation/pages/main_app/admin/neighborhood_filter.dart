import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class NeighborhoodFilter extends StatefulWidget {
  NeighborhoodFilter(
      {super.key, this.onSelected});

  final List<String> clusterFilters = [
    NeighborhoodStrings.clusterFilterAll,
    NeighborhoodStrings.clusterFilterNeedCaptain,
    NeighborhoodStrings.clusterFilterParticipate,
  ];
  final void Function(String?)? onSelected;

  @override
  State<NeighborhoodFilter> createState() => _NeighborhoodTypeFilterState();
}

class _NeighborhoodTypeFilterState extends State<NeighborhoodFilter> {
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
    final filters = widget.clusterFilters;
    return Container(
      padding: EdgeInsets.all(16),
      child: DropdownMenu<String>(
        width: 200,
        label: const Text(NeighborhoodStrings.selectFilter),
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
