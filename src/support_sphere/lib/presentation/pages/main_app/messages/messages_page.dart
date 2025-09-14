import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/clusters.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/repositories/user.dart';
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

  String title = "Messages";
  bool _isLoading = true;

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
    setState(() => _isLoading = true);

    final user = await userRepo.getPersonProfileByUserId(userId: myUserId);
    log.fine("MY USER ID: $myUserId, profile: ${user!.profile!.id}");

    cluster = await clusterRepo.getClusterByUser(myUserId);
    title = "${cluster!.name} Messages";
    //log.fine("CLUSTER: $cluster");

    final allUsers = await userRepo.getAllMembers();
    profileCache.addAll(allUsers);
    //log.fine(">>> $profileCache");

    if (!mounted) return; // avoid calling setState after dispose

    setState(() => _isLoading = false);
  }

  Person? getProfile(String userId) {
    final person = profileCache[userId];
    //log.fine("===== Found profile for $userId: $person");
    return person;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                              profile: getProfile(messages[index].fromId),
                              myUserId: myUserId,
                            );
                          },
                        ),
                ),
                MessageBar(cluster: cluster!),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
} // -- end of state

/// Set of widget that contains TextField and Button to submit message
class MessageBar extends StatefulWidget {
  MessageBar({Key? key, required this.cluster}) : super(key: key);

  final Cluster cluster;

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

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
                onPressed: () => _submitMessage(context, widget.cluster.id),
                child: const Text('Send Message'), // FIXME formatting, text
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage(BuildContext context, String toId) async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();

    //log.fine("Sent message from:$myUserId, to:$toId: $text");
    MessagesRepository().sendMessage(myUserId, toId, text);
    setState(() {

    });
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
