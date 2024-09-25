import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/operational_event.dart';
import 'package:support_sphere/data/repositories/app.dart';

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
      (data) => add(AppOnModeChanged(data.appMode)),
    );

    _userRoleSubscription = _appRepository.currentUserRole.listen(
      (userRole) => add(AppOnUserRoleChanged(userRole)),
    );
  }

  final AppRepository _appRepository;
  late final StreamSubscription<OperationalEvent>
      _operationalStatusSubscription;
  late final StreamSubscription<String> _userRoleSubscription;

  void _onModeChanged(AppOnModeChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  void _updateStatus(AppOnStatusChangeRequested event, Emitter<AppState> emit) {
    _appRepository.changeOperationalStatus(operationalStatus: event.mode.name);
  }

  void _onBottomNavIndexChanged(
      AppOnBottomNavIndexChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedBottomNavIndex: event.selectedBottomNavIndex));
  }

  @override
  Future<void> close() {
    _operationalStatusSubscription.cancel();
    _userRoleSubscription.cancel();
    return super.close();
  }
}
