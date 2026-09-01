import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
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

  Future<int> unreadCount(String groupId, String userId) {
    return supabase.rpc(
      'get_unread_count',
      params: {'p_profile_id': userId, 'p_group_id': groupId},
    );
  }

  Future<void> markMessagesRead(String groupId, String userId) async {
    final msgs = await supabase.messages
        .select()
        .eq(Messages.c_toId, groupId)
        .withConverter(Messages.converter);
    for (Messages msg in msgs) {
      await supabase.message_reads.upsert(MessageReads.insert(
        messageId: msg.id,
        profileId: userId,
      ));
    }
  }

  Future<String> lastUnreadMessage(String groupId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('to_id', groupId)
        .order('sent_on', ascending: false)
        .limit(1)
        .maybeSingle();
    return response?['content'] ?? ' ';
  }

  Future<DateTime?> lastMessageSentAt(String groupId) async {
    final response = await supabase
        .from('messages')
        .select('sent_on')
        .eq('to_id', groupId)
        .order('sent_on', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    return DateTime.parse(response['sent_on'] as String);
  }

  Future<bool> hasResourceRemovedMessage(String groupId) async {
    final row = await supabase
        .from('messages')
        .select('id')
        .eq('to_id', groupId)
        .eq('message_type', 'resource_removed')
        .limit(1)
        .maybeSingle();
    return row != null;
  }

  Future<void> sendMessage({
    required String fromProfileId,
    required String groupId,
    required String text,
    required MESSAGEURGENCY urgency,
    String? requestId,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final messageId = const UuidV4().generate();
    log.fine("Sending message from:$fromProfileId, to:$groupId: $text");
    await supabase.from('messages').insert({
      'id': messageId,
      'from_id': fromProfileId,
      'to_id': groupId,
      'request_id': requestId,
      'urgency': urgency.name,
      'content': text,
      'sent_on': DateTime.now().toIso8601String(),
      'message_type': messageType,
      'metadata': metadata,
    });
    await supabase.message_reads.upsert(MessageReads.insert(
      messageId: messageId,
      profileId: fromProfileId,
    ));
  }
}
