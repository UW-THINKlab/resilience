

class MessageUrgency {
  static const String normal = "normal";
  static const String important = "important";
  static const String urgent = "urgent";
  static const String emergency = "emergency";
}

class Message {
  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.content,
    required this.urgency,
    required this.sentOn,
  });

  /// ID of the message
  final String id;

  /// ID of the user who posted the message
  final String fromId;

  // to profile or group
  final String toId;

  /// Text content of the message
  final String content;

  /// Date and time when the message was created
  final DateTime sentOn;

  final String urgency;

  Message.fromJson({
    required Map<String, dynamic> json,
  })  : id = json['id'],
        fromId = json['from_id'],
        toId = json['to_id'],
        content = json['content'],
        urgency = json['urgency'],
        sentOn = DateTime.parse(json['sent_on']);

  static List<Message> fromList(List<dynamic> stuff) {
    List<Message> messages = [];
    for (var msg in stuff) {
      messages.add(Message.fromJson(json: msg));
    }
    return messages;
  }

}
