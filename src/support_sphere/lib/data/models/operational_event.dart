import 'package:equatable/equatable.dart';
import 'package:support_sphere/logic/bloc/app_bloc.dart';


class OperationalEvent extends Equatable{
  const OperationalEvent({
    required this.id,
    required this.created_by,
    required this.created_at,
    required this.operational_status,
  });

  final String id;
  final String created_by;
  final String created_at;
  final String operational_status;

  @override
  List<Object?> get props => [id, created_by, created_at, operational_status];

  AppModes get appMode {
    switch (operational_status) {
      case 'NORMAL':
        return AppModes.normal;
      case 'EMERGENCY':
        return AppModes.emergency;
      case 'TEST':
        return AppModes.testEmergency;
      default:
        return AppModes.normal;
    }
  }

  
}