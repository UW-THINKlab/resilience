import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/presentation/components/filter_search_bar.dart';

class ClusterSearchBar extends StatelessWidget {
  const ClusterSearchBar({super.key, this.onQueryChanged});

  final void Function(String)? onQueryChanged;

  @override
  Widget build(BuildContext context) => FilterSearchBar(
        labelText: NeighborhoodStrings.searchClusters,
        onQueryChanged: onQueryChanged,
      );
}
