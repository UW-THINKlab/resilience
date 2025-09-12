import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:support_sphere/utils/supabase.dart';

const preloader = Center(child: CircularProgressIndicator(color: Colors.blueGrey));

final log = Logger('MessagesPage');

// ASIDE: "Groups" include households, clusters

// from github.com/supabase-community/flutter-chat/blob/main/lib/pages/chat_page.dart


/// Initial page for cluster messaging.
/// Cluster captains get special display,
/// and ability to send "urgent" messages
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
  final UserRepository userRepo = UserRepository();
  final MessagesRepository messageRepo = MessagesRepository();
  final ClusterRepository clusterRepo = ClusterRepository();

  late final Stream<List<Message>> messagesStream;
  late final Stream<Person?> profileStream;
  late final Cluster? cluster;
  late final String clusterId;
  final Map<String,Person> profileCache = {};
  late final String myUserId;
  late final Person? myUser;

  @override
  void initState() {
    myUserId = supabase.auth.currentUser!.id;
    messagesStream = messageRepo.messagesTo(supabase.auth.currentUser!);
    profileStream = userRepo.personForId(userId: myUserId);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    //setState(() => _isLoading = true);

    myUser = await userRepo.getPersonProfileByUserId(userId: myUserId);
    log.fine("MY USER ID: $myUserId, profile: ${myUser!.profile!.id}");
    cluster = await clusterRepo.getClusterByUser(myUserId);

    final members = await userRepo.getAllMembers();
    for (var member in members) {
      profileCache[member!.id] = member;
    }

    // if (!mounted) return; // avoid calling setState after dispose
    // setState(() {
    //   _data = result;
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    //final MyAuthUser authUser = context.select((AuthenticationBloc bloc) => bloc.state.user);
    //final profileStream = _userRepo.personForAuthUser(user: authUser);
    final title = cluster != null && cluster!.name != null ? cluster!.name : 'Messages';
    return Scaffold(
      appBar: AppBar(title: Text(title!)),
      body: StreamBuilder<List<Message>>(
        stream: messagesStream,
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
                              profile: profileCache[messages[index].fromId],
                              myUserId: myUserId,
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

    final MessagesRepository _messageRepo = MessagesRepository();
    _messageRepo.sendMessage(myUserId, "_clusterId", text);


    // try {
    //   await supabase.from('messages').insert({
    //    'profile_id': myUserId,
    //    'content': text,
    //   });
    // } on PostgrestException catch (error) {
    //   log.warning("ERROR: ${error.message}");
    //   //context.showErrorSnackBar(message: error.message);
    // } catch (_) {
    //   //context.showErrorSnackBar(message: unexpectedErrorMessage);
    //   log.warning("Unknown error in _submitMessage");
    // }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    Key? key,
    required this.message,
    required this.profile,
    required this.myUserId,
  }) : super(key: key);

  final Message message;
  final Person? profile;
  final String? myUserId;

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
      Text("${profile?.givenName} ${profile?.familyName} on ${message.sentOn.toString()}"),
      const SizedBox(width: 60),
    ];
    if (message.fromId == myUserId) {
      chatContents = chatContents.reversed.toList();
    }
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
