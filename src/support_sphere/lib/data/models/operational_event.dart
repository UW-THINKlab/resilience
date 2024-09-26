import 'package:equatable/equatable.dart';

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
}
