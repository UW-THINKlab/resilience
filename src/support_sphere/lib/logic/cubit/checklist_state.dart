part of 'checklist_cubit.dart';

/// handle checklist main page state
class ChecklistState extends Equatable {
  const ChecklistState({
    this.toBeDoneChecklists = const [],
    this.completedChecklists = const [],
  });

  final List<UserChecklist> toBeDoneChecklists;
  final List<UserChecklist> completedChecklists;

  @override
  List<Object?> get props => [toBeDoneChecklists, completedChecklists];

  ChecklistState copyWith({
    List<UserChecklist>? toBeDoneChecklists,
    List<UserChecklist>? completedChecklists,
  }) {
    return ChecklistState(
      toBeDoneChecklists: toBeDoneChecklists ?? this.toBeDoneChecklists,
      completedChecklists: completedChecklists ?? this.completedChecklists,
    );
  }
}