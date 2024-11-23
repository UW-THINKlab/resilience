part of 'checklist_management_cubit.dart';

/// handle checklist management (for LEAP users only) page state
class ChecklistManagementState extends Equatable {
  const ChecklistManagementState({
    this.allChecklists =
        const [], // for LEAP users, they can see all checklists instead of the checklists for a specific user
  });

  final List<Checklist> allChecklists;

  @override
  List<Object> get props =>
      [allChecklists];

  ChecklistManagementState copyWith({
    List<Checklist>? allChecklists,
  }) {
    return ChecklistManagementState(
      allChecklists: allChecklists ?? this.allChecklists,
    );
  }
}
