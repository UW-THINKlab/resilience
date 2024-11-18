import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/data/models/frequency.dart';
import 'package:support_sphere/data/services/checklist_service.dart';

/// Repository for checklist interactions.
/// This class is responsible for handling checklist-related data operations.
class ChecklistRepository {
  final ChecklistService _checklistService = ChecklistService();

  /// Get user checklists by user id.
  /// Returns a list of [Checklist] objects.
  Future<List<Checklist>> getUserChecklists(String userId) async {
    final data = await _checklistService.getUserChecklists(userId);

    return data.map((item) {
      final checklistInfo = item['checklists'];
      final frequencyInfo = checklistInfo['frequency'];
      final steps = checklistInfo['checklist_steps_orders'] ?? [];

      return Checklist(
          id: item['id'],
          title: checklistInfo['title'],
          description: checklistInfo['description'] ?? '',
          steps: steps
              ?.map<ChecklistSteps>((step) => ChecklistSteps(
                  id: step['id'],
                  priority: step['priority'],
                  label: step['checklist_steps']['label'],
                  description: step['checklist_steps']['description'],
                  isCompleted: step['checklist_steps_states'][0]?['is_completed'],
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
}
