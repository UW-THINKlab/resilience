import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/data/models/frequency.dart';
import 'package:support_sphere/data/services/checklist_service.dart';

/// Repository for checklist interactions.
/// This class is responsible for handling checklist-related data operations.
class ChecklistRepository {
  final ChecklistService _checklistService = ChecklistService();

  /// Get user checklists by user id.
  /// Returns a list of [UserChecklist] objects.
  Future<List<UserChecklist>> getUserChecklistsByUserId(String userId) async {
    final data = await _checklistService.getUserChecklistsByUserId(userId);

    return data.map((item) {
      final checklistInfo = item['checklists'];
      final frequencyInfo = checklistInfo['frequency'];
      final steps = checklistInfo['checklist_steps_orders'] ?? [];

      return UserChecklist(
          id: item['id'],
          title: checklistInfo['title'],
          description: checklistInfo['description'] ?? '',
          steps: steps
              ?.map<UserChecklistSteps>((step) => UserChecklistSteps(
                  id: step['id'],
                  priority: step['priority'],
                  label: step['checklist_steps']['label'],
                  description: step['checklist_steps']['description'],
                  stepStateId: step['checklist_steps_states'][0]?['id'],
                  isCompleted: step['checklist_steps_states'][0]
                      ?['is_completed'],
                  updatedAt:
                      DateTime.parse(step['checklist_steps']['updated_at'])))
              .toList(),
          frequency: frequencyInfo != null
              ? Frequency(
                  id: frequencyInfo['id'],
                  name: frequencyInfo['name'],
                  numDays: frequencyInfo['num_days'])
              : null,
          completedAt: item['completed_at'] != null
              ? DateTime.parse(item['completed_at'])
              : null,
          updatedAt: DateTime.parse(checklistInfo['updated_at']));
    }).toList();
  }

  Future<void> updateStepStatus(String stepStateId, bool isCompleted) async {
    await _checklistService.updateStepStatus(stepStateId, isCompleted);
  }

  Future<bool> areAllStepsCompleted(String userChecklistId, String userId) async {
    return await _checklistService.areAllStepsCompleted(userChecklistId, userId);
  }

  Future<void> updateChecklistCompletedAt(String userChecklistId, DateTime? completedAt) async {
    await _checklistService.updateChecklistCompletedAt(userChecklistId, completedAt);
  }

  Future<List<Checklist>> getAllChecklists() async {
    final data = await _checklistService.getAllChecklists();

    return data.map((item) {
      final frequencyInfo = item['frequency'];
      final steps = item['checklist_steps_orders'] ?? [];
      final completions = (item['user_checklists'] as List<dynamic>?)
          ?.where((userChecklist) => userChecklist['completed_at'] != null)
          .length ?? 0;

      return Checklist(
          id: item['id'],
          title: item['title'],
          description: item['description'] ?? '',
          priority: item['priority'],
          notes: item['notes'] ?? '',
          steps: steps
              ?.map<ChecklistSteps>((step) => ChecklistSteps(
                  id: step['checklist_steps']['id'],
                  orderId: step['id'],
                  priority: step['priority'],
                  label: step['checklist_steps']['label'],
                  description: step['checklist_steps']['description'],
                  updatedAt:
                      DateTime.parse(step['checklist_steps']['updated_at'])))
              .toList(),
          frequency: frequencyInfo != null
              ? Frequency(
                  id: frequencyInfo['id'],
                  name: frequencyInfo['name'],
                  numDays: frequencyInfo['num_days'])
              : null,
          completions: completions,
          updatedAt: DateTime.parse(item['updated_at']));
    }).toList();
  }

  Future<void> upsertChecklist(Checklist checklist) async {
    final checklistData = {
      'id': checklist.id,
      'title': checklist.title,
      'description': checklist.description,
      'priority': checklist.priority.toUpperCase(),
      'notes': checklist.notes,
      'frequency_id': checklist.frequency?.id,
      'updated_at': checklist.updatedAt!.toIso8601String(),
    };

    await _checklistService.upsertChecklist(checklistData);
  }

  Future<void> upsertChecklistSteps(
      String checklistId, List<ChecklistSteps> steps) async {
    final stepsData = steps
        .map((step) => {
              'id': step.id,
              'label': step.label,
              'description': step.description,
              'updated_at': step.updatedAt!.toIso8601String(),
            })
        .toList();
    final stepsOrdersData = steps
        .map((step) => {
              'id': step.orderId,
              'checklist_id': checklistId,
              'checklist_step_id': step.id,
              'priority': step.priority,
              'updated_at': step.updatedAt!.toIso8601String(),
            })
        .toList();

    await _checklistService.upsertChecklistSteps(stepsData);
    await _checklistService.upsertChecklistStepsOrders(stepsOrdersData);
  }

  Future<void> deleteChecklistSteps(String checklistId, List<String> stepIds) async {
    await _checklistService.deleteChecklistSteps(checklistId, stepIds);
  }

  Future<List<Frequency>> getFrequencies() async {
    final frequencies = await _checklistService.getFrequencies();

    return frequencies
        .map((freq) => Frequency(
              id: freq['id'],
              name: freq['name'],
              numDays: freq['num_days'],
            ))
        .toList();
  }
}
