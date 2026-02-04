import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/utils/supabase.dart';

class MessagesRepository {
  //final SupabaseClient _supabaseClient = supabase;

  // Future<PostgrestList?> _queryMessages(String toId) async {
  //   return await _supabaseClient.from('messages').select().order('name', ascending: true);
  // }

  Stream<List<Message>> messagesTo(User user) {
    return supabase.from('messages')
      .stream(primaryKey: [user.id])
      .order('sent_on')
      .map((maps) => maps.map((map) => Message.fromJson(json: map))
      .toList());
  }

  // Stream<List<Message>> getMessages(User user) async* {
  //   print(user);
  //   //final MyAuthUser authUser = context.select((AuthenticationBloc bloc) => bloc.state.user);

  //   yield [
  //     Message(
  //       id: "5432",
  //       fromId: "20",
  //       toId: "25",
  //       content: "test message 1",
  //       urgency: MessageUrgency.normal,
  //       sentOn: DateTime.now(),
  //     ),
  //   ];
  // }
}
