import 'package:flutter/material.dart';
import 'package:support_sphere/data/models/checklist.dart';

class ChecklistStepItem extends StatelessWidget {
  final ChecklistSteps step;
  final int totalSteps;
  final VoidCallback? onToggle;

  const ChecklistStepItem({
    super.key,
    required this.step,
    required this.totalSteps,
    this.onToggle,
  });

  Color _completedTextColor(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    final isCompletedStylesEnabled = onToggle != null && step.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Step's checkbox
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 6, left: 8, right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: step.isCompleted
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Step's priority & label in one row
                      Row(
                        children: [
                          Text(
                            '${step.priority + 1}/$totalSteps:',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      decoration: isCompletedStylesEnabled
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isCompletedStylesEnabled
                                          ? _completedTextColor(context)
                                          : null,
                                    ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                step.label ?? '',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  decoration: isCompletedStylesEnabled
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompletedStylesEnabled
                                      ? _completedTextColor(context)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// Step's description
                      if (step.description != null &&
                          step.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          step.description!,
                          style: TextStyle(
                            decoration: isCompletedStylesEnabled
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompletedStylesEnabled
                                ? _completedTextColor(context)
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
