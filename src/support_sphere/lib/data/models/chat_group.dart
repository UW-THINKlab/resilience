import 'package:equatable/equatable.dart';

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  int? unreadCount;
  String? lastMessage;
  DateTime? lastMessageTime;
  // final List<String> members;  // User IDs in group
  
  ChatGroup({
    required this.id,
    required this.name,
    this.description,
    // this.lastMessage,
    // this.lastMessageTime,
    // required this.members,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      //TODO implement last message, time, unread count, group members
      // lastMessage: json['last_message'],
      // lastMessageTime: json['last_message_time'] != null
      //     ? DateTime.parse(json['last_message_time'])
      //     : null,
      // unreadCount: json['unread_count'] ?? 0,
      // members: List<String>.from(json['members'] ?? []),

    );
  }

  @override
  // List<Object?> get props => [id, name, lastMessage, lastMessageTime, unreadCount, members];
  List<Object?> get props => [id, name];
}
