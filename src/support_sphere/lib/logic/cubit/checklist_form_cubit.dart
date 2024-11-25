import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/data/models/frequency.dart';
import 'package:support_sphere/data/repositories/checklist.dart';
import 'package:uuid/v4.dart';

part 'checklist_form_state.dart';

class ChecklistFormCubit extends Cubit<ChecklistFormState> {
  ChecklistFormCubit({required this.authUser, this.initialChecklist})
      : super(ChecklistFormState(
          steps: initialChecklist?.steps ?? const [],
        )) {
    fetchAllFrequencies();
  }

  final AuthUser authUser;
  final Checklist? initialChecklist;
  final ChecklistRepository _checklistRepository = ChecklistRepository();

  void addStep() {
    final steps = List<ChecklistSteps>.from(state.steps);

    steps.add(ChecklistSteps(
      id: const UuidV4().generate(),
      orderId: const UuidV4().generate(),
      priority: steps.length,
    ));

    emit(state.copyWith(steps: steps));
  }

  void removeStep(int index) {
    final steps = List<ChecklistSteps>.from(state.steps);
    steps.removeAt(index);

    // Update priorities for remaining steps
    for (var i = 0; i < steps.length; i++) {
      steps[i] = ChecklistSteps(
        id: steps[i].id,
        orderId: steps[i].orderId,
        priority: i,
        label: steps[i].label,
        description: steps[i].description,
        updatedAt: steps[i].updatedAt,
      );
    }

    emit(state.copyWith(steps: steps));
  }

  void reorderStep(int oldIndex, int newIndex) {
    final steps = List<ChecklistSteps>.from(state.steps);
    final step = steps.removeAt(oldIndex);
    steps.insert(newIndex, step);

    // Update priorities for all steps
    for (var i = 0; i < steps.length; i++) {
      steps[i] = ChecklistSteps(
        id: steps[i].id,
        orderId: steps[i].orderId,
        priority: i,
        label: steps[i].label,
        description: steps[i].description,
        updatedAt: steps[i].updatedAt,
      );
    }

    emit(state.copyWith(steps: steps));
  }

  Future<void> fetchAllFrequencies() async {
    try {
      final frequencies = await _checklistRepository.getFrequencies();
      emit(state.copyWith(frequencies: frequencies));
    } catch (error) {
      /// TODO: handle errors
      print(error);
    }
  }

  Future<void> saveChecklist(
      {String? id, required Map<String, dynamic> formData}) async {
    try {
      emit(state.copyWith(status: ChecklistFormStatus.loading));

      final checklistId = id ??
          // insert new uuid when creating new checklist
          const UuidV4().generate();
      final checklist = Checklist(
        id: checklistId,
        title: formData['title'],
        description: formData['description'],
        notes: formData['notes'],
        priority: formData['priority'],
        frequency: state.frequencies
            .where((freq) => freq.id == formData['frequency_id'])
            .singleOrNull,
        steps: state.steps,
        updatedAt: DateTime.now(), // TODO: handle updated_at with DB Trigger
      );
      final steps = state.steps.map<ChecklistSteps>((step) {
        return ChecklistSteps(
          id: step.id,
          orderId: step.orderId,
          priority: step.priority,
          label: formData['step_label_${step.id}'],
          description: formData['step_description_${step.id}'],
          updatedAt: DateTime.now(), // TODO: handle updated_at with DB Trigger
        );
      }).toList();

      if (initialChecklist != null) {
        final deletedStepIds = initialChecklist!.steps
            .where((oldStep) => !steps.any((newStep) => newStep.id == oldStep.id))
            .map((step) => step.id)
            .toList();

        if (deletedStepIds.isNotEmpty) {
          await _checklistRepository.deleteChecklistSteps(checklistId, deletedStepIds);
        }
      }

      await _checklistRepository.upsertChecklist(checklist);
      await _checklistRepository.upsertChecklistSteps(checklistId, steps);

      emit(state.copyWith(status: ChecklistFormStatus.success));
    } catch (error) {
      /// TODO: handle errors
      print(error);
    }
  }
}
