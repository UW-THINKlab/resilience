import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/data/repositories/checklist.dart';

part 'checklist_state.dart';

class ChecklistCubit extends Cubit<ChecklistState> {
  ChecklistCubit(this.authUser) : super(const ChecklistState()) {
    fetchUserChecklists(authUser.uuid);
  }

  final AuthUser authUser;
  final ChecklistRepository _checklistRepository = ChecklistRepository();

  Future<void> fetchUserChecklists(String userId) async {
    try {
      final checklists = await _checklistRepository.getUserChecklists(userId);

      emit(state.copyWith(
          toBeDoneChecklists: checklists
              .where((checklist) => checklist.completedAt == null)
              .toList(),
          completedChecklists: checklists
              .where((checklist) => checklist.completedAt != null)
              .toList()));
    } catch (error) {
      /// TODO: handle errors
      print(error);
    }
  }

  Future<void> updateStepStatus(String stepStateId, bool isCompleted, String userChecklistId) async {
    if (state.isLoading) return; // TODO: replace it with loading UI

    try {
      emit(state.copyWith(isLoading: true));

      await _checklistRepository.updateStepStatus(stepStateId, isCompleted);
      
      /// TODO: Consider using RPC for better atomicity and performance
      final allCompleted = await _checklistRepository.areAllStepsCompleted(userChecklistId, authUser.uuid);

      await _checklistRepository.updateChecklistCompletedAt(
        userChecklistId, 
        allCompleted ? DateTime.now() : null
      );

      /// Refresh checklist data
      await fetchUserChecklists(authUser.uuid);
    } catch (error) {
      /// TODO: handle errors
      print(error);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
