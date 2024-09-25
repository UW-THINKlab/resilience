part of 'app_bloc.dart';

enum AppModes {
  normal,
  emergency,
  testEmergency,
}

class AppState extends Equatable {
  const AppState({
    this.currentUserRole = '',
    this.mode = AppModes.normal,
    this.selectedBottomNavIndex = 0,
  });

  final String currentUserRole;
  final AppModes mode;
  final int selectedBottomNavIndex;

  @override
  List<Object> get props => [currentUserRole, mode, selectedBottomNavIndex];

  AppState copyWith({
    String? currentUserRole,
    AppModes? mode,
    int? selectedBottomNavIndex,
  }) {
    return AppState(
      currentUserRole: currentUserRole ?? this.currentUserRole,
      mode: mode ?? this.mode,
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}
