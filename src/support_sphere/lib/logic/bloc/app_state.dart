part of 'app_bloc.dart';

class AppState extends Equatable {
  const AppState({
    this.selectedBottomNavIndex = 0,
  });

  final int selectedBottomNavIndex;

  @override
  List<Object> get props => [selectedBottomNavIndex];

  AppState copyWith({
    int? selectedBottomNavIndex,
  }) {
    return AppState(
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}
