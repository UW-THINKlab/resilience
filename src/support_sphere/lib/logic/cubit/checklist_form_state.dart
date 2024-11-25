part of 'checklist_form_cubit.dart';

enum ChecklistFormStatus { initial, loading, success, failure }

class ChecklistFormState extends Equatable {
  final List<ChecklistSteps> steps;
  final ChecklistFormStatus status;
  final List<Frequency> frequencies;

  const ChecklistFormState({
    this.steps = const [],
    this.status = ChecklistFormStatus.initial,
    this.frequencies = const [],
  });

  @override
  List<Object?> get props => [
        steps,
        status,
        frequencies,
      ];

  ChecklistFormState copyWith({
    List<ChecklistSteps>? steps,
    ChecklistFormStatus? status,
    List<Frequency>? frequencies,
  }) {
    return ChecklistFormState(
      steps: steps ?? this.steps,
      status: status ?? this.status,
      frequencies: frequencies ?? this.frequencies,
    );
  }

  /// TODO: use them to implement UI logic
  bool get isInitial => status == ChecklistFormStatus.initial;
  bool get isLoading => status == ChecklistFormStatus.loading;
  bool get isSuccess => status == ChecklistFormStatus.success;
  bool get isFailure => status == ChecklistFormStatus.failure;
}
