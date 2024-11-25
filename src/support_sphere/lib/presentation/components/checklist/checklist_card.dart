import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/utils/extensions.dart';

class ChecklistCard extends StatelessWidget {
  final String title;
  final String? frequency;
  final int? stepCount;
  final String? description;
  final String? notes;
  final String? priority;
  final int? completions;
  final bool isInProgress;
  final DateTime? completedDate;
  final VoidCallback? onButtonClicked;
  final Widget? trailing;
  final bool isLEAP;

  const ChecklistCard({
    super.key,
    required this.title,
    this.stepCount = 0,
    this.frequency = '',
    this.description = '',
    this.priority = '',
    this.completions = 0,
    this.notes = '',
    this.onButtonClicked,
    this.isInProgress = false,
    this.completedDate,
    this.trailing,
    this.isLEAP = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onButtonClicked,
        child: Stack(children: [
          /// we can implement checkboxes for bulk actions by simply adding the "leading" property of ListTile
          ListTile(
            contentPadding:
                const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
            titleAlignment: ListTileTitleAlignment.top,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: trailing,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(children: [
                  /// Steps Count
                  if (stepCount != null && stepCount != 0) ...[
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 3),
                    Text(ChecklistStrings.stepsCount(stepCount!)),
                    const SizedBox(width: 16),
                  ],

                  /// Frequency
                  if (frequency != null && frequency!.isNotEmpty) ...[
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(frequency!),
                    const SizedBox(width: 16),
                  ],

                  /// Priority & Completions
                  if (isLEAP) ...[
                    Text('Priority: ${priority!.capitalize()}'),
                    const SizedBox(width: 16),
                    Text('Completions: $completions')
                  ],
                ]),

                /// Completed Date
                if (completedDate != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    ChecklistStrings.completedOnDate(
                        DateFormat.yMMMd('en').format(completedDate!)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 10),

                /// Description
                Text(
                  description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                /// Notes
                if (isLEAP) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Notes: $notes',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),

          /// "In Progress" Indicator at the top right
          if (stepCount != null && stepCount! > 0 && isInProgress)
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
}
