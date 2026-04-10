import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/utils/supabase.dart';

class ChatRepository {
  Future<List<ChatGroup>> getUserChatGroups(String userId) async {
    final response = await supabase
        .from('group_members')
        .select('''
          groups(
            id, 
            name
          )
        ''')
        .eq('people_id', userId);

    print('Got response: ${response}');

    final groups = response.map((item) {
      final json = item['groups'] ?? item; // Flatten json- response comes out nested
      return ChatGroup.fromJson(json);
    }).toList();
    return groups;
    //TODO implement:
    // id, name, last_message, last_message_time, unread_count
  }
}