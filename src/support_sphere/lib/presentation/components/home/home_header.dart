import 'package:flutter/material.dart';
import 'package:support_sphere/data/models/clusters.dart';

class HomeHeader extends StatelessWidget {
  final Cluster cluster;

  const HomeHeader({super.key, required this.cluster});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        cluster.name ?? '',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
