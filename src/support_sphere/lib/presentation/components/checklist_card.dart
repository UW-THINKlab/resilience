import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ChecklistCard extends StatelessWidget {
  final String title;
  final int stepCount;
  final String frequency;
  final String description;
  final bool isInProgress;
  final DateTime? completedDate;
  final VoidCallback onButtonClicked;

  const ChecklistCard({
    super.key,
    required this.title,
    required this.stepCount,
    required this.frequency,
    this.description = '',
    this.onButtonClicked = _defaultButtonClicked,
    this.isInProgress = false,
    this.completedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onButtonClicked,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 3),
                    Text(ChecklistStrings.stepsCount(stepCount)),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(frequency),
                  ],
                ),
                if (completedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    ChecklistStrings.completedOnDate(
                        _formatDate(completedDate!)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isInProgress)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  ChecklistStrings.inProgress,
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // TODO: update proper date formatting
    return date.toString().split(' ')[0];
  }

  static void _defaultButtonClicked() {}
}
