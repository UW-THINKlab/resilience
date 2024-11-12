import 'package:equatable/equatable.dart';

class Checklist extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int stepCount;
  final String frequency;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final int? lastCompletedVersion;

  const Checklist({
    required this.id,
    required this.title,
    this.description,
    required this.stepCount,
    required this.frequency,
    required this.isCompleted,
    this.completedAt,
    this.dueDate,
    this.lastCompletedVersion = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    stepCount,
    frequency,
    isCompleted,
    completedAt,
    dueDate,
    lastCompletedVersion,
  ];
}
