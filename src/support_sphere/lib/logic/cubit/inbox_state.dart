part of 'inbox_cubit.dart';

class InboxState extends Equatable {
  const InboxState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ChatGroup> groups;
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [groups, isLoading, error];

  InboxState copyWith({
    List<ChatGroup>? groups,
    bool? isLoading,
    String? error,
  }) => InboxState(
    groups: groups ?? this.groups,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}