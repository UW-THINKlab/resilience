import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/presentation/components/filter_search_bar.dart';

class HouseholdSearchBar extends StatelessWidget {
  const HouseholdSearchBar({super.key, this.onQueryChanged});

  final void Function(String)? onQueryChanged;

  @override
  Widget build(BuildContext context) => FilterSearchBar(
        labelText: ClusterAdminStrings.searchHouseholds,
        onQueryChanged: onQueryChanged,
      );
}
