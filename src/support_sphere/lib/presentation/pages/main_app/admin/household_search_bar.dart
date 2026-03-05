
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class HouseholdSearchBar extends StatefulWidget {
  final void Function(String)? onQueryChanged;

  const HouseholdSearchBar({super.key, this.onQueryChanged});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<HouseholdSearchBar> {
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
          labelText: ClusterAdminString.searchHouseholds,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
