part of 'app_bloc.dart';

class AppEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppOnBottomNavIndexChanged extends AppEvent {
  AppOnBottomNavIndexChanged(this.selectedBottomNavIndex);

  final int selectedBottomNavIndex;

  @override
  List<Object> get props => [selectedBottomNavIndex];
}
