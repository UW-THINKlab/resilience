import 'package:equatable/equatable.dart';
import 'package:support_sphere/logic/bloc/app_bloc.dart';

class OperationalEvent extends Equatable {
  const OperationalEvent({
    required this.id,
    required this.createdBy,
    required this.createdAt,
    required this.operationalStatus,
  });

  final String id;
  final String createdBy;
  final String createdAt;
  final String operationalStatus;

  @override
  List<Object?> get props => [id, createdBy, createdAt, operationalStatus];

  AppModes get appMode {
    switch (operationalStatus) {
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
