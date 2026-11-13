part of 'inbox_cubit.dart';

class InboxState extends Equatable {
  const InboxState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.offline = false,
  });

  final List<ChatGroup> groups;
  final bool isLoading;
  final String? error;

  /// Whether [error] is because the server couldn't be reached.
  final bool offline;

  @override
  List<Object?> get props => [groups, isLoading, error, offline];

  InboxState copyWith({
    List<ChatGroup>? groups,
    bool? isLoading,
    String? error,
    bool offline = false,
  }) =>
      InboxState(
        groups: groups ?? this.groups,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        offline: offline,
      );
}
