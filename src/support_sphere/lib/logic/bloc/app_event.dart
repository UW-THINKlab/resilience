part of 'app_bloc.dart';

class AppEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppOnModeChanged extends AppEvent {
  AppOnModeChanged(this.mode);

  final String mode;

  @override
  List<Object> get props => [mode];
}

class AppOnStatusChangeRequested extends AppEvent {
  AppOnStatusChangeRequested(this.mode);

  final String mode;

  @override
  List<Object> get props => [mode];
}

class AppOnBottomNavIndexChanged extends AppEvent {
  AppOnBottomNavIndexChanged(this.selectedBottomNavIndex);

  final int selectedBottomNavIndex;

  @override
  List<Object> get props => [selectedBottomNavIndex];
}
