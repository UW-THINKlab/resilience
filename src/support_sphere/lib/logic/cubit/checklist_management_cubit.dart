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

  final AuthUser authUser;
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
}
