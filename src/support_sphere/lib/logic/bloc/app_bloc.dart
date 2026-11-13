import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/models/operational_event.dart';
import 'package:support_sphere/data/repositories/app.dart';
import 'package:support_sphere/data/services/offline_cache.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AppRepository appRepository})
      : _appRepository = appRepository,
        super(const AppState()) {
    on<AppOnBottomNavIndexChanged>(_onBottomNavIndexChanged);
    on<AppOnModeChanged>(_onModeChanged);
    on<AppOnStatusChangeRequested>(_updateStatus);

    _operationalStatusSubscription = _appRepository.operationalStatus.listen(
      (data) {
        _hasLiveStatus = true;
        OfflineCache.markOnline();
        unawaited(OfflineCache.save(_statusKey, data.operationalStatus));
        add(AppOnModeChanged(data.operationalStatus));
      },
      onError: (_) => _useSavedStatus(offline: true),
    );
    // Start from the last status seen, so an emergency declared earlier still
    // shows if the device is offline now. Added as an event (not the initial
    // state) so the emergency banner listener fires.
    _useSavedStatus(offline: false);
  }

  static const _statusKey = 'operational_status';

  final AppRepository _appRepository;
  late final StreamSubscription<OperationalEvent>
      _operationalStatusSubscription;
  bool _hasLiveStatus = false;

  Future<void> _useSavedStatus({required bool offline}) async {
    final saved = await OfflineCache.load(_statusKey);
    if (saved == null || _hasLiveStatus || isClosed) return;
    if (offline) OfflineCache.markShowingSaved(saved.savedAt);
    final mode = saved.data;
    if (mode is String) add(AppOnModeChanged(mode));
  }

  void _onModeChanged(AppOnModeChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  void _updateStatus(AppOnStatusChangeRequested event, Emitter<AppState> emit) {
    _appRepository.changeOperationalStatus(operationalStatus: event.mode);
  }

  void _onBottomNavIndexChanged(
      AppOnBottomNavIndexChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedBottomNavIndex: event.selectedBottomNavIndex));
  }

  @override
  Future<void> close() {
    _operationalStatusSubscription.cancel();
    return super.close();
  }
}
