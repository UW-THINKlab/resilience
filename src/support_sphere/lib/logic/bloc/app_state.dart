part of 'app_bloc.dart';

enum AppModes {
  normal,
  emergency,
  testEmergency,
}

class AppState extends Equatable {
  const AppState({
    this.mode = AppModes.normal,
    this.selectedBottomNavIndex = 0,
  });

  final AppModes mode;
  final int selectedBottomNavIndex;

  @override
  List<Object> get props => [mode, selectedBottomNavIndex];

  AppState copyWith({
    AppModes? mode,
    int? selectedBottomNavIndex,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}
