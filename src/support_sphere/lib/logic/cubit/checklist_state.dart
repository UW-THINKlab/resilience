part of 'checklist_cubit.dart';

/// handle checklist main page state
class ChecklistState extends Equatable {
  const ChecklistState({
    this.checklists = const [],
  });
  
  final List<Checklist> checklists;

  @override
  List<Object?> get props => [checklists];

  ChecklistState copyWith({
    List<Checklist>? checklists,
  }) {
    return ChecklistState(
      checklists: checklists ?? this.checklists,
    );
  }
}