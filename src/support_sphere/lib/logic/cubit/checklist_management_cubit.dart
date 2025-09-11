import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/checklist.dart';
import 'package:support_sphere/data/repositories/checklist.dart';

part 'checklist_management_state.dart';

class ChecklistManagementCubit extends Cubit<ChecklistManagementState> {
  ChecklistManagementCubit(this.authUser)
      : super(const ChecklistManagementState()) {
    fetchAllChecklists();
  }

  final MyAuthUser authUser;
  final ChecklistRepository _checklistRepository = ChecklistRepository();

  Future<void> fetchAllChecklists() async {
    try {
      final checklists = await _checklistRepository.getAllChecklists();

      emit(state.copyWith(allChecklists: checklists));
    } catch (error) {
      /// TODO: handle errors
      print(error);
    }
  }

  void showChecklistForm({Checklist? checklist}) {
    emit(state.copyWith(
      showForm: true,
      // if there is no checklist, it means creating new checklist
      editingChecklist: checklist,
    ));
  }

  void hideChecklistForm() {
    emit(state.copyWith(
      showForm: false,
      editingChecklist: null,
    ));
  }
}
