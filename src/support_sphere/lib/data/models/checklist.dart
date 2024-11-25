import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/frequency.dart';

class Checklist extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? notes;
  final List<ChecklistSteps> steps;
  final int completions;
  final String priority;
  final Frequency? frequency;
  final DateTime? updatedAt;

  const Checklist({
    required this.id,
    required this.title,
    this.description = '',
    this.notes = '',
    this.priority = 'Low',
    this.steps = const [],
    this.completions = 0,
    this.frequency,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    notes,
    priority,
    steps,
    completions,
    frequency,
    updatedAt
  ];
}

class UserChecklist extends Equatable {
  final String id; // it's for user_checklist's id instead of checklist's id
  final String title;
  final String? description;
  final List<UserChecklistSteps> steps;
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
  final String orderId;
  final int priority;
  final String? label;
  final String? description;
  final DateTime? updatedAt;

  const ChecklistSteps({
    required this.id,
    required this.orderId,
    required this.priority,
    this.label = '',
    this.description = '',
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    priority,
    label,
    description,
    updatedAt,
  ];
}

class UserChecklistSteps extends Equatable {
  final String id;
  final int priority;
  final String? label;
  final String? description;
  final String stepStateId;
  final bool isCompleted;
  final DateTime? updatedAt;

  const UserChecklistSteps({
    required this.id,
    required this.priority,
    this.label = '',
    this.description = '',
    required this.stepStateId,
    required this.isCompleted,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    priority,
    label,
    description,
    isCompleted,
    updatedAt,
    stepStateId,
  ];
}
