import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:support_sphere/presentation/components/checklist_card.dart';
import 'package:support_sphere/logic/cubit/checklist_cubit.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ChecklistBody extends StatelessWidget {
  const ChecklistBody({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthUser authUser = context.select(
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

class _ToBeDoneTab extends StatelessWidget {
  const _ToBeDoneTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        if (state.toBeDoneChecklists.isEmpty) {
          return const _AllDoneView();
        }

        return ListView.builder(
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
                // TODO: Navigate to checklist detail page
              },
            );
          },
        );
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        if (state.completedChecklists.isEmpty) {
          return const Center(
            child: Text(ChecklistStrings.noCompletedChecklist),
          );
        }

        return ListView.builder(
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
                // TODO: Navigate to completed checklist review
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
                ChecklistStrings.congratulations +
                    ChecklistStrings.nextChecklistDue(
                        _getClosestDueDate(state.completedChecklists)),
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
