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
      /// TBD: handle errors
      print(error);
    }
  }
}
