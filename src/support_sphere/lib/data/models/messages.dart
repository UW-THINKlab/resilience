class Message {
  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.content,
    required this.createdAt,
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
  final DateTime createdAt;

  Message.fromJson({
    required Map<String, dynamic> json,
  })  : id = json['id'],
        fromId = json['from_id'],
        toId = json['to_id'],
        content = json['content'],
        createdAt = DateTime.parse(json['created_at']);

  static List<Message> fromList(List<dynamic> stuff) {
    List<Message> messages = [];
    for (var msg in stuff) {
      messages.add(Message.fromJson(json: msg));
    }
    return messages;
  }

}
