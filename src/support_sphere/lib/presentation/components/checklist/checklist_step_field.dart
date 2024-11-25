import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class ChecklistStepField extends StatelessWidget {
  final String id;
  final int index;
  final int totalSteps;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final String? initialLabel;
  final String? initialDescription;

  const ChecklistStepField({
    super.key,
    required this.id,
    required this.index,
    required this.totalSteps,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.initialLabel,
    this.initialDescription,
  });

  @override
  Widget build(BuildContext context) {
    final labelId = 'step_label_$id';
    final descriptionId = 'step_description_$id';

    return Card(
      key: Key('step_$id'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Step ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                /// Action buttons
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: onMoveUp,
                  ),
                if (index < totalSteps - 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: onMoveDown,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Step's label field
            FormBuilderTextField(
              key: Key(labelId),
              name: labelId,
              initialValue: initialLabel,
              decoration: const InputDecoration(
                labelText: ChecklistStrings.stepLabelFieldLabel,
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.maxLength(200),
              ]),
            ),
            const SizedBox(height: 16),

            /// Step's description field
            FormBuilderTextField(
              key: Key(descriptionId),
              name: descriptionId,
              initialValue: initialDescription,
              decoration: const InputDecoration(
                labelText: ChecklistStrings.stepDescriptionFieldLabel,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
