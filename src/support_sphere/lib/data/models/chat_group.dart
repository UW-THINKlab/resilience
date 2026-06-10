import 'package:equatable/equatable.dart';

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final List<String> members; // User IDs in group

  const ChatGroup({
    required this.id,
    required this.name,
    this.description,
    this.lastMessage,
    this.lastMessageTime,
    required this.members,
    required this.unreadCount,
  });

  factory ChatGroup.from(
    String id,
    String name, {
    int unreadCount = 0,
    List<String> members = const [],
    String? description,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return ChatGroup(
      id: id,
      name: name,
      description: description,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      members: members,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, lastMessage, lastMessageTime, unreadCount, members];
}
