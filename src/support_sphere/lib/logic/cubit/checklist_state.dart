part of 'checklist_cubit.dart';

/// handle checklist main page state
class ChecklistState extends Equatable {
  const ChecklistState({
    this.toBeDoneChecklists = const [],
    this.completedChecklists = const [],
  });
  
  final List<Checklist> toBeDoneChecklists;
  final List<Checklist> completedChecklists;

  @override
  List<Object?> get props => [toBeDoneChecklists, completedChecklists];

  ChecklistState copyWith({
    List<Checklist>? toBeDoneChecklists,
    List<Checklist>? completedChecklists,
  }) {
    return ChecklistState(
      toBeDoneChecklists: toBeDoneChecklists ?? this.toBeDoneChecklists,
      completedChecklists: completedChecklists ?? this.completedChecklists,
    );
  }
}