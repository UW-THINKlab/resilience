part of 'app_bloc.dart';

class AppState extends Equatable {
  const AppState({
    this.mode = AppModes.normal,
    this.selectedBottomNavIndex = 0,
  });

  final String mode;
  final int selectedBottomNavIndex;

  @override
  List<Object> get props => [mode, selectedBottomNavIndex];

  AppState copyWith({
    String? mode,
    int? selectedBottomNavIndex,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}
