import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppOnBottomNavIndexChanged>(_onBottomNavIndexChanged);
    on<AppOnModeChanged>(_onModeChanged);
  }

  void _onModeChanged(AppOnModeChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  void _onBottomNavIndexChanged(
      AppOnBottomNavIndexChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedBottomNavIndex: event.selectedBottomNavIndex));
  }
}
