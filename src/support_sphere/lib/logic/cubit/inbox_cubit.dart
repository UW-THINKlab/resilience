import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/data/services/offline_cache.dart';

part 'inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  InboxCubit(this.authUser) : super(const InboxState()) {
    fetchGroups();
  }

  final MyAuthUser authUser;
  final ChatRepository _repo = ChatRepository();

  Future<void> fetchGroups() async {
    emit(state.copyWith(isLoading: true));
    try {
      final groups = await _repo.getUserChatGroups(authUser.uuid);
      // A fresh state, so an error from an earlier attempt is cleared.
      emit(InboxState(groups: groups));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        offline: OfflineCache.isNetworkError(e),
      ));
    }
  }

  Future<void> deleteGroup(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repo.deleteGroup(id);
      final groups = await _repo.getUserChatGroups(authUser.uuid);
      emit(InboxState(groups: groups));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        offline: OfflineCache.isNetworkError(e),
      ));
    }
  }
}
