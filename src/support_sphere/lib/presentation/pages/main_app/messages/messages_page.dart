import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:support_sphere/utils/supabase.dart';

const preloader = Center(child: CircularProgressIndicator(color: Colors.blueGrey));

final log = Logger('MessagesPage');


/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const MessagesPage(),
    );
  }

  @override
  State<MessagesPage> createState() => MessagesState();
}

class MessagesState extends State<MessagesPage> {
  //final UserRepository _userRepo = UserRepository();
  final MessagesRepository _messageRepo = MessagesRepository();
  //late final List<Message> _messages;

  late final Stream<List<Message>> _messagesStream;
  //late final Stream<Person> _profileStream;
  //final Map<String, Profile> _profileCache = {};

  @override
  void initState() {
    final supabase = Supabase.instance.client;
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = _messageRepo.messagesTo(supabase.auth.currentUser!);

    //_profileStream = _userRepo.personForAuthUser(user: supabase.auth.currentUser!);
    //final user = supabase.auth.currentUser;

    //_messagesStream = _messageRepo.getMessages(user!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    //final MyAuthUser authUser = context.select((AuthenticationBloc bloc) => bloc.state.user);
    //final profileStream = _userRepo.personForAuthUser(user: authUser);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')), // FIXME title of message group
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('Start your conversation now :)'),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _MessageBubble(
                              message: messages[index],
                              // FIXME add profile info
                              //profile: _profileCache[message.profileId],
                            );
                          },
                        ),
                ),
                const _MessageBar(),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}


/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar({
    Key? key,
  }) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(context),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage(BuildContext context) async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();

    try {
      await supabase.from('messages').insert({
       'profile_id': myUserId,
       'content': text,
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    Key? key,
    required this.message,
    //required this.profile,
  }) : super(key: key);

  final Message message;
  //final Profile? profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      CircleAvatar(
        child: Center(child: Icon(
          URGENCY_ICONS[message.urgency],
          color:  URGENCY_COLOR[message.urgency],
        ))),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: URGENCY_COLOR[message.urgency],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
      ),
      const SizedBox(width: 12),
      Text(timeago.format(message.sentOn, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    //if (message.isMine) {
    //  chatContents = chatContents.reversed.toList();
    //}
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }

  static const URGENCY_COLOR = {
    MessageUrgency.emergency:  Colors.red,
    MessageUrgency.urgent: Colors.purpleAccent,
    MessageUrgency.important:Colors.orange,
    MessageUrgency.normal: Colors.blue,
    "default": Colors.grey,
  };

  static const URGENCY_ICONS = {
    MessageUrgency.emergency: Icons.emergency,
    MessageUrgency.urgent: Icons.explicit_sharp,
    MessageUrgency.important: Icons.label_important,
    MessageUrgency.normal: Icons.mail_rounded,
  };

}
