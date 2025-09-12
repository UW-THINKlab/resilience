import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/utils/supabase.dart';

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
    try {
      await supabase.from('messages').insert({
       'from_id': userId,
       'to_id': toId,
       'content': text,
       'sent_on': DateTime.now(),
       'urgency': "normal",
      });
    } on PostgrestException catch (error) {
      log.warning("ERROR: ${error.message}");
      //context.showErrorSnackBar(message: error.message);
    } catch (_) {
      //context.showErrorSnackBar(message: unexpectedErrorMessage);
      log.warning("Unknown error in _submitMessage");
    }
  }
}
