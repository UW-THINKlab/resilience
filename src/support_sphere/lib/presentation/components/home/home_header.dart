import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:support_sphere/data/models/clusters.dart';

class HomeHeader extends StatelessWidget {
  final Cluster cluster;

  const HomeHeader({super.key, required this.cluster});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Row(
        children: [
          Icon(Ionicons.location_outline,
              size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            cluster.name ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
