import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/presentation/components/checklist/checklist_card.dart';
import 'package:support_sphere/logic/cubit/checklist_management_cubit.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ChecklistManagementBody extends StatelessWidget {
  const ChecklistManagementBody({super.key});

  void _showChecklistSettingsMenu(BuildContext context, Checklist checklist,
      BuildContext buttonContext) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
            position.dx, position.dy, button.size.width, button.size.height),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: [
        PopupMenuItem(
          child: const Text(ChecklistStrings.edit),
          onTap: () {
            // TODO: Navigate to ChecklistEditPage
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => ChecklistManagementCubit(authUser),
      child: Column(
        children: [
          // Page Title
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              ChecklistStrings.manageChecklists,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Create new checklist button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to CreateChecklistPage
                },
                icon: const Icon(Icons.add),
                label: const Text(ChecklistStrings.newChecklist),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<ChecklistManagementCubit,
                ChecklistManagementState>(
              builder: (context, state) {
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: state.allChecklists.length,
                  itemBuilder: (context, index) {
                    final checklist = state.allChecklists[index];
                    return ChecklistCard(
                      title: checklist.title,
                      stepCount: checklist.steps.length,
                      frequency: checklist.frequency?.name,
                      description: checklist.description,
                      priority: checklist.priority,
                      completions: checklist.completions,
                      notes: checklist.notes,
                      isLEAP: true,
                      trailing: Builder(
                        builder: (buttonContext) => IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showChecklistSettingsMenu(
                            context,
                            checklist,
                            buttonContext,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
