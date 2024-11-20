part of 'checklist_cubit.dart';

/// handle checklist main page state
class ChecklistState extends Equatable {
  const ChecklistState({
    this.toBeDoneChecklists = const [],
    this.completedChecklists = const [],
    this.isLoading = false,
  });

  final List<UserChecklist> toBeDoneChecklists;
  final List<UserChecklist> completedChecklists;
  final bool isLoading;

  @override
  List<Object> get props =>
      [toBeDoneChecklists, completedChecklists, isLoading];

  ChecklistState copyWith({
    List<UserChecklist>? toBeDoneChecklists,
    List<UserChecklist>? completedChecklists,
    bool? isLoading,
  }) {
    return ChecklistState(
      toBeDoneChecklists: toBeDoneChecklists ?? this.toBeDoneChecklists,
      completedChecklists: completedChecklists ?? this.completedChecklists,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
