import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/logic/cubit/checklist_cubit.dart';
import 'package:support_sphere/presentation/components/checklist/checklist_step_item.dart';

class ChecklistStepsPage extends StatelessWidget {
  final String userChecklistId;
  final VoidCallback onBack;
  final bool isInToBeDoneTab;

  const ChecklistStepsPage({
    super.key,
    required this.userChecklistId,
    required this.onBack,
    this.isInToBeDoneTab = false,
  });

  bool _areAllStepsCompleted(List<UserChecklistSteps> steps) {
    return steps.every((step) => step.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        /// when user completed all steps, the current checklist will be moved to completedChecklists so we need to get it from the combined list
        final currentChecklist =
            (state.toBeDoneChecklists + state.completedChecklists)
                .firstWhere((checklist) => checklist.id == userChecklistId);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  /// Back button
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      ChecklistStrings.allChecklist,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: onBack,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                color: Colors.grey[200],
                child: ListView(
                  children: [
                    /// Checklist's title
                    Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 12, left: 16, right: 16),
                        child: Text(
                          currentChecklist.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (currentChecklist.frequency?.name != null) ...[
                      const SizedBox(height: 8),

                      /// Checklist's frequency
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(ChecklistStrings.completeFrequency(
                                  currentChecklist.frequency!.name!)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (currentChecklist.description != null &&
                        currentChecklist.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          /// Checklist's description
                          child: Text(
                            currentChecklist.description!,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    /// Steps List UI
                    ...List.generate(
                      currentChecklist.steps.length,
                      (index) => UserChecklistStepItem(
                          step: currentChecklist.steps[index],
                          totalSteps: currentChecklist.steps.length,
                          onToggle: isInToBeDoneTab
                              ? () {
                                  context
                                      .read<ChecklistCubit>()
                                      .updateStepStatus(
                                        currentChecklist
                                            .steps[index].stepStateId,
                                        !currentChecklist
                                            .steps[index].isCompleted,
                                        currentChecklist.id,
                                      );
                                }
                              : null),
                    ),
                  ],
                ),
              ),
            ),

            /// Congratulations message container when user has completed all steps
            if (isInToBeDoneTab &&
                _areAllStepsCompleted(currentChecklist.steps))
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ChecklistStrings.done,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentChecklist.frequency != null
                            ? ChecklistStrings.congratulations +
                                ChecklistStrings.nextDue(
                                    _getNextDueDate(currentChecklist))
                            : ChecklistStrings.congratulations,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        ChecklistStrings.checkCompletedTab,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getNextDueDate(UserChecklist userChecklist) {
    if (userChecklist.completedAt != null && userChecklist.frequency != null) {
      DateTime nextDue = userChecklist.completedAt!.add(
        Duration(days: userChecklist.frequency!.numDays ?? 0),
      );
      return DateFormat.yMMMd('en').format(nextDue);
    }

    return '';
  }
}
