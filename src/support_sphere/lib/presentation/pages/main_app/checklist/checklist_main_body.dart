import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/presentation/components/checklist_card.dart';
import 'package:support_sphere/logic/cubit/checklist_cubit.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
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
              tabs: const [
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
  const _ToBeDoneTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        final incompletedChecklists = state.checklists
            .where((checklist) => !checklist.isCompleted)
            .toList();

        if (incompletedChecklists.isEmpty) {
          return const _AllDoneView();
        }

        return ListView.builder(
          itemCount: incompletedChecklists.length,
          itemBuilder: (context, index) {
            final checklist = incompletedChecklists[index];

            return ChecklistCard(
              title: checklist.title,
              stepCount: checklist.stepCount,
              frequency: checklist.frequency,
              description: checklist.description,
              isInProgress: checklist.lastCompletedVersion > 0,
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
  const _CompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        final completedChecklists = state.checklists
            .where((checklist) => checklist.isCompleted)
            .toList();

        if (completedChecklists.isEmpty) {
          return const Center(
            child: Text(ChecklistStrings.noCompletedChecklist),
          );
        }

        return ListView.builder(
          itemCount: completedChecklists.length,
          itemBuilder: (context, index) {
            final checklist = completedChecklists[index];
            return ChecklistCard(
              title: checklist.title,
              stepCount: checklist.stepCount,
              frequency: checklist.frequency,
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
  const _AllDoneView({super.key});

  @override
  Widget build(BuildContext context) {
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
              ChecklistStrings.congratulations(
                  '2024/11/12'), // Replace it with real data
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
  }
}
