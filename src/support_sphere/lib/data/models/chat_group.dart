import 'package:equatable/equatable.dart';

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int? unreadCount;
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
    this.unreadCount,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] ?? 0,
      members: List<String>.from(json['members'] ?? []),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, lastMessage, lastMessageTime, unreadCount, members];
}
