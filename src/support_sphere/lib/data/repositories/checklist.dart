import 'package:support_sphere/data/models/checklist.dart';
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
      final recurringType = item['frequency'];
      final checklistState = item['user_checklist_state'];
      
      return Checklist(
        id: item['id'],
        title: item['title'],
        description: item['description'],
        stepCount: item['checklist_steps']?.length ?? 0,
        frequency: recurringType['name'],
        isCompleted: checklistState?['completed'] ?? false,
        completedAt: checklistState?['completed_at'] != null 
            ? DateTime.parse(checklistState['completed_at'])
            : null,
        dueDate: item['due_date'] != null 
            ? DateTime.parse(item['due_date'])
            : null,
        lastCompletedVersion: item['last_completed_version'],
      );
    }).toList();
  }
}
