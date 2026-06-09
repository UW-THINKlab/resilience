import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:uuid/v4.dart' show UuidV4;

final log = Logger('MessagesRepository');

class MessagesRepository {
  Stream<List<Message>> messagesTo(User user) {
    return supabase
        .from('messages')
        .stream(primaryKey: [user.id])
        .order('sent_on')
        .map((maps) => maps.map((map) => Message.fromJson(json: map)).toList());
  }

  Stream<List<Message>> messagesFor(User user, String groupId) {
    return supabase
        .from('messages')
        .stream(primaryKey: [user.id])
        .eq('to_id', groupId)
        .order('sent_on')
        .map((maps) => maps.map((map) => Message.fromJson(json: map)).toList());
  }

  Future<int> unreadCount(String groupId, String time) async {
    final List<dynamic> data = await supabase
        .from('messages')
        .select('id')
        .eq('to_id', groupId)
        .gte('sent_on', time);
    return data.length;
  }

  Future<String> lastUnreadMessage(
      String userId, String groupId, String time) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('to_id', groupId)
        .neq('from_id', userId)
        .gte('sent_on', time)
        .order('sent_on', ascending: false)
        .limit(1)
        .maybeSingle();
    return response?['content'] ?? ' ';
  }

  Future<void> sendMessage({
    required String fromProfileId,
    required String groupId,
    required String text,
    String? requestId,
    String urgency = 'normal',
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    log.fine("Sending message from:$fromProfileId, to:$groupId: $text");
    await supabase.from('messages').insert({
      'id': const UuidV4().generate(),
      'from_id': fromProfileId,
      'to_id': groupId,
      'request_id': requestId,
      'urgency': urgency,
      'content': text,
      'sent_on': DateTime.now().toIso8601String(),
      'message_type': messageType,
      'metadata': metadata,
    });
  }
}
