import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart' show UuidV4;

final log = Logger('MessagesRepository');

class MessagesRepository {
  Stream<List<Message>> messagesTo(User user) {
    return supabase.from('messages')
      .stream(primaryKey: [user.id])
      .order('sent_on')
      .map((maps) => maps.map((map) => Message.fromJson(json: map))
      .toList());
  }

  Stream<List<Message>> messagesFor(User user, String groupId) {
    return supabase.from('messages')
      .stream(primaryKey: [user.id])
      .eq('to_id', groupId)
      .order('sent_on')
      .map((maps) => maps.map((map) => Message.fromJson(json: map))
      .toList());
  }

  Future<void> sendMessage(String userId, String toId, String text) async {
    log.fine("Sending message from:$userId, to:$toId: $text");

    final dateSent = DateTime.now();
    await supabase.from('messages').insert({
      'id': const UuidV4().generate(), // autogen by table def?
      'from_id': userId,
      'to_id': toId,
      'content': text,
      'sent_on': dateSent.toIso8601String(),
      'urgency': "normal",
    });
  }
}
