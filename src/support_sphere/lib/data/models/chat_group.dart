import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/models/generated_classes.dart';

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final String lastMessage;
  final String? description;
  final List<String> members;
  final GROUP_CHAT_TYPE type;
  final int unreadCount;
  final RESERVATION_STATUS? reservationStatus;
  final bool isRequester;

  const ChatGroup({
    required this.id,
    required this.name,
    required this.lastMessage,
    this.description,
    required this.members,
    required this.type,
    required this.unreadCount,
    this.reservationStatus,
    this.isRequester = false,
  });

  factory ChatGroup.from(
    String id,
    String name, {
    List<String> members = const [],
    String? description,
    String lastMessage = '',
    GROUP_CHAT_TYPE type = GROUP_CHAT_TYPE.chat,
    int unreadCount = 0,
    RESERVATION_STATUS? reservationStatus,
    bool isRequester = false,
  }) {
    return ChatGroup(
      id: id,
      name: name,
      lastMessage: lastMessage,
      description: description,
      members: members,
      type: type,
      unreadCount: unreadCount,
      reservationStatus: reservationStatus,
      isRequester: isRequester,
    );
  }

  ChatGroup copyWith({
    RESERVATION_STATUS? reservationStatus,
    bool? isRequester,
  }) {
    return ChatGroup(
      id: id,
      name: name,
      lastMessage: lastMessage,
      description: description,
      members: members,
      type: type,
      unreadCount: unreadCount,
      reservationStatus: reservationStatus ?? this.reservationStatus,
      isRequester: isRequester ?? this.isRequester,
    );
  }

  @override
  List<Object?> get props => [id, name, members, reservationStatus, isRequester];
}
