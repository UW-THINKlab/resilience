part of 'checklist_management_cubit.dart';

/// handle checklist management (for LEAP users only) page state
class ChecklistManagementState extends Equatable {
  const ChecklistManagementState({
    this.allChecklists =
        const [], // for LEAP users, they can see all checklists instead of the checklists for a specific user
    this.showForm = false,
    this.editingChecklist,
  });

  final List<Checklist> allChecklists;
  final bool showForm;
  final Checklist? editingChecklist;

  @override
  List<Object?> get props => [allChecklists, showForm, editingChecklist];

  ChecklistManagementState copyWith({
    List<Checklist>? allChecklists,
    bool? showForm,
    Checklist? editingChecklist,
  }) {
    return ChecklistManagementState(
      allChecklists: allChecklists ?? this.allChecklists,
      showForm: showForm ?? this.showForm,
      editingChecklist: editingChecklist,
      /*
        For editingChecklist, don't use ?? operator here because we want to allow null values to be set.
        If we used ??, when editingChecklist is null, it would fallback to the previous value,
        preventing us from clearing the editing state.
      */
    );
  }
}
