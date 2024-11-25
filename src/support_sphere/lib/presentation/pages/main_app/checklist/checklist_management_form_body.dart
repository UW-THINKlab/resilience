import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/logic/cubit/checklist_form_cubit.dart';
import 'package:support_sphere/presentation/components/checklist/checklist_step_field.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/constants/priority.dart';
import 'package:support_sphere/utils/extensions.dart';

class ChecklistFormBody extends StatefulWidget {
  const ChecklistFormBody({
    super.key,
    this.initialChecklist,
    required this.onCancel,
  });

  final Checklist? initialChecklist;
  final VoidCallback onCancel;

  @override
  State<ChecklistFormBody> createState() => _ChecklistFormBodyState();
}

class _ChecklistFormBodyState extends State<ChecklistFormBody> {
  late final GlobalKey<FormBuilderState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormBuilderState>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChecklistFormCubit, ChecklistFormState>(
      listener: (context, state) {
        if (state.status == ChecklistFormStatus.success) {
          widget.onCancel();
        }
      },
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: _buildForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onCancel,
      ),
      title: Text(
        widget.initialChecklist != null
            ? ChecklistStrings.editPreparednessChecklist
            : ChecklistStrings.addNewPreparednessChecklist,
      ),
      actions: [
        BlocBuilder<ChecklistFormCubit, ChecklistFormState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: state.status == ChecklistFormStatus.loading
                    ? null
                    : () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          context.read<ChecklistFormCubit>().saveChecklist(
                                id: widget.initialChecklist?.id,
                                formData: _formKey.currentState!.value,
                              );
                        }
                      },
                child: const Text(ChecklistStrings.save),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title field
            FormBuilderTextField(
              name: 'title',
              initialValue: widget.initialChecklist?.title,
              decoration: const InputDecoration(
                labelText: ChecklistStrings.titleFieldLabel,
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.maxLength(100),
              ]),
            ),
            const SizedBox(height: 16),

            /// Frequency field
            BlocBuilder<ChecklistFormCubit, ChecklistFormState>(
              builder: (context, state) {
                if (state.frequencies.isEmpty) {
                  /// Show loading indicator while fetching frequencies
                  return const CircularProgressIndicator();
                }

                return FormBuilderDropdown<String>(
                  name: 'frequency_id',
                  initialValue: widget.initialChecklist?.frequency?.id,
                  decoration: const InputDecoration(
                    labelText: ChecklistStrings.frequencyFieldLabel,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      child: Text(ChecklistStrings.pleaseSelect),
                    ),
                    ...state.frequencies.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency.id,
                        child: Text(frequency.name ?? ''),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            /// Priority level field
            FormBuilderDropdown<String>(
              name: 'priority',
              initialValue: widget.initialChecklist?.priority.capitalize() ??
                  priorityLevels[1],
              decoration: const InputDecoration(
                labelText: ChecklistStrings.priorityFieldLabel,
                border: OutlineInputBorder(),
              ),
              items: priorityLevels.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),

            /// Description field
            FormBuilderTextField(
              name: 'description',
              initialValue: widget.initialChecklist?.description,
              decoration: const InputDecoration(
                labelText: ChecklistStrings.descriptionFieldLabel,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),

            /// Notes field
            FormBuilderTextField(
              name: 'notes',
              initialValue: widget.initialChecklist?.notes,
              decoration: const InputDecoration(
                labelText: ChecklistStrings.notesFieldLabel,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            /// Steps section
            BlocBuilder<ChecklistFormCubit, ChecklistFormState>(
              builder: (context, state) {
                return ListView.builder(
                  shrinkWrap: true,
                  /*
                    Disable scrolling for this ListView since it's inside a SingleChildScrollView
                    This prevents nested scrolling conflicts and ensures smooth scrolling experience
                  */
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.steps.length,
                  itemBuilder: (context, index) {
                    final step = state.steps[index];
                    return ChecklistStepField(
                      id: step.id,
                      index: index,
                      totalSteps: state.steps.length,
                      initialLabel: step.label,
                      initialDescription: step.description,
                      onRemove: () =>
                          context.read<ChecklistFormCubit>().removeStep(index),
                      onMoveUp: index > 0
                          ? () => context
                              .read<ChecklistFormCubit>()
                              .reorderStep(index, index - 1)
                          : null,
                      onMoveDown: index < state.steps.length - 1
                          ? () => context
                              .read<ChecklistFormCubit>()
                              .reorderStep(index, index + 1)
                          : null,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            /// Add new step button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.read<ChecklistFormCubit>().addStep(),
                icon: const Icon(Icons.add),
                label: const Text(ChecklistStrings.addNewStep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
