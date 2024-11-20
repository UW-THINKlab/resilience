import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';

class ChecklistService {
  final SupabaseClient _supabaseClient = supabase;

  Future<List<Map<String, dynamic>>> getUserChecklists(String userId) async {
    return await _supabaseClient
        .from('user_checklists')
        .select('''
          id,
          user_profile_id,
          completed_at,
          checklists (
            id,
            title,
            description,
            notes,
            updated_at,
            frequency (
              id,
              name,
              num_days
            ),
            checklist_steps_orders (
              id,
              priority,
              checklist_steps (
                id,
                label,
                description,
                updated_at
              ),
              checklist_steps_states (
                id,
                user_profile_id,
                is_completed
              )
            )
          )
        ''')
        .eq('user_profile_id', userId)
        .eq('checklists.checklist_steps_orders.checklist_steps_states.user_profile_id',
            userId)
        .order('priority',
            referencedTable: 'checklists.checklist_steps_orders',
            ascending: true)
        .order('id', ascending: true);
  }

  Future<void> updateStepStatus(String stepStateId, bool isCompleted) async {
    await _supabaseClient
        .from('checklist_steps_states')
        .update({'is_completed': isCompleted}).eq('id', stepStateId);
  }

  Future<bool> areAllStepsCompleted(
      String userChecklistId, String userId) async {
    final result = await _supabaseClient
        .from('user_checklists')
        .select('''
            checklists (
              checklist_steps_orders (
                checklist_steps_states (
                  id,
                  is_completed
                )
              )
            )
          )
        ''')
        .eq('id', userChecklistId)
        .eq('user_profile_id', userId)
        .eq('checklists.checklist_steps_orders.checklist_steps_states.user_profile_id',
            userId)
        .single();

    return result['checklists']['checklist_steps_orders'].every(
        (order) => order['checklist_steps_states'][0]['is_completed'] == true);
  }

  Future<void> updateChecklistCompletedAt(
      String userChecklistId, DateTime? completedAt) async {
    await _supabaseClient
        .from('user_checklists')
        .update({'completed_at': completedAt?.toIso8601String()}).eq(
            'id', userChecklistId);
  }
}
