import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:support_sphere/presentation/components/checklist/checklist_card.dart';
import 'package:support_sphere/presentation/pages/main_app/checklist/checklist_steps_body.dart';
import 'package:support_sphere/logic/cubit/checklist_cubit.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ChecklistBody extends StatelessWidget {
  const ChecklistBody({super.key});

  @override
  Widget build(BuildContext context) {
    final MyAuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => ChecklistCubit(authUser),
      child: const DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: ChecklistStrings.toBeDone),
                Tab(text: ChecklistStrings.completed),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ToBeDoneTab(),
                  _CompletedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToBeDoneTab extends StatefulWidget {
  const _ToBeDoneTab();

  @override
  State<_ToBeDoneTab> createState() => _ToBeDoneTabState();
}

class _ToBeDoneTabState extends State<_ToBeDoneTab> {
  bool _showingSteps = false;
  UserChecklist? _selectedChecklist;

  @override
  Widget build(BuildContext context) {
    if (_showingSteps && _selectedChecklist != null) {
      return ChecklistStepsPage(
        userChecklistId: _selectedChecklist!.id,
        isInToBeDoneTab: true,
        onBack: () => setState(() {
          _showingSteps = false;
          _selectedChecklist = null;
        }),
      );
    }

    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        if (state.toBeDoneChecklists.isEmpty) {
          return const _AllDoneView();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: state.toBeDoneChecklists.length,
          itemBuilder: (context, index) {
            final checklist = state.toBeDoneChecklists[index];

            return ChecklistCard(
              title: checklist.title,
              stepCount: checklist.steps.length,
              frequency: checklist.frequency?.name,
              description: checklist.description,
              isInProgress: checklist.steps.any((step) => step.isCompleted),
              onButtonClicked: () {
                setState(() {
                  _showingSteps = true;
                  _selectedChecklist = checklist;
                });
              },
            );
          },
        );
      },
    );
  }
}

class _CompletedTab extends StatefulWidget {
  const _CompletedTab();

  @override
  State<_CompletedTab> createState() => _CompletedTabState();
}

class _CompletedTabState extends State<_CompletedTab> {
  bool _showingSteps = false;
  UserChecklist? _selectedChecklist;

  @override
  Widget build(BuildContext context) {
    if (_showingSteps && _selectedChecklist != null) {
      return ChecklistStepsPage(
        userChecklistId: _selectedChecklist!.id,
        onBack: () => setState(() {
          _showingSteps = false;
          _selectedChecklist = null;
        }),
      );
    }

    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        if (state.completedChecklists.isEmpty) {
          return const Center(
            child: Text(ChecklistStrings.noCompletedChecklist),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: state.completedChecklists.length,
          itemBuilder: (context, index) {
            final checklist = state.completedChecklists[index];
            return ChecklistCard(
              title: checklist.title,
              stepCount: checklist.steps.length,
              frequency: checklist.frequency?.name,
              description: checklist.description,
              completedDate: checklist.completedAt,
              onButtonClicked: () {
                setState(() {
                  _showingSteps = true;
                  _selectedChecklist = checklist;
                });
              },
            );
          },
        );
      },
    );
  }
}

class _AllDoneView extends StatelessWidget {
  const _AllDoneView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
        builder: (context, state) {
      final closestDueDate = _getClosestDueDate(state.completedChecklists);

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ChecklistStrings.allDone,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                closestDueDate.isNotEmpty
                    ? ChecklistStrings.congratulationsAllDone +
                        ChecklistStrings.nextChecklistDue(closestDueDate)
                    : ChecklistStrings.congratulationsAllDone,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                ChecklistStrings.checkCompletedTab,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getClosestDueDate(List<UserChecklist> completedChecklists) {
    DateTime? closestDate;

    for (var checklist in completedChecklists) {
      if (checklist.completedAt != null && checklist.frequency != null) {
        DateTime nextDue = checklist.completedAt!.add(
          Duration(days: checklist.frequency!.numDays ?? 0),
        );

        if (closestDate == null || nextDue.isBefore(closestDate)) {
          closestDate = nextDue;
        }
      }
    }

    return closestDate != null
        ? DateFormat.yMMMd('en').format(closestDate)
        : '';
  }
}
