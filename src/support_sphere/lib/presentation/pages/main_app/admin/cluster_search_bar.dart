
import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ClusterSearchBar extends StatefulWidget {
  final void Function(String)? onQueryChanged;

  const ClusterSearchBar({super.key, this.onQueryChanged});

  @override
  ClusterBarState createState() => ClusterBarState();
}

class ClusterBarState extends State<ClusterSearchBar> {
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
          labelText: NeighborhoodStrings.searchClusters,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
