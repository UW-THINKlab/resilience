import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/frequency.dart';

class UserChecklist extends Equatable {
  final String id; // it's for user_checklist's id instead of checklist's id
  final String title;
  final String? description;
  final List<ChecklistSteps> steps;
  final Frequency? frequency;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const UserChecklist({
    required this.id,
    required this.title,
    this.description = '',
    this.steps = const [],
    this.frequency,
    this.completedAt,
    required this.updatedAt
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    steps,
    frequency,
    completedAt,
    updatedAt
  ];
}

class ChecklistSteps extends Equatable {
  final String id;
  final int priority;
  final String? label;
  final String? description;
  final bool isCompleted;
  final DateTime updatedAt;

  const ChecklistSteps({
    required this.id,
    required this.priority,
    this.label = '',
    this.description = '',
    required this.isCompleted,
    required this.updatedAt
  });

  @override
  List<Object?> get props => [
    id,
    priority,
    label,
    description,
    isCompleted,
    updatedAt
  ];
}
