import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:timeago/timeago.dart';

const preloader =
    Center(child: CircularProgressIndicator(color: Colors.blueGrey));

final log = Logger('MessagesPage');

///TODO- display chat group name at the top of the messages pane
///TODO- add ability to send "urgent" messages (red highlight, icon) for cluster captains

class MessagesPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const MessagesPage(
      {super.key, required this.groupId, required this.groupName});

  @override
  State<MessagesPage> createState() => MessagesState();
}

class MessagesState extends State<MessagesPage> {
  final UserRepository userRepo = UserRepository();
  final MessagesRepository messageRepo = MessagesRepository();
  final ClusterRepository clusterRepo = ClusterRepository();

  late final Stream<List<Message>> messagesStream;
  late final Stream<Person?> profileStream;
  final Map<String, Person> profileCache = {};
  late final String myUserId;

  @override
  void initState() {
    log.fine('🚀 initState groupId: "${widget.groupId}"');
    super.initState();

    myUserId = supabase.auth.currentUser!.id;
    messagesStream = messageRepo.messagesTo(supabase.auth.currentUser!);
    profileStream = userRepo.personForId(userId: myUserId);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    log.fine('✅ Group ID: ${widget.groupId}');
    log.fine('✅ My User: $myUserId');
    setState(() => {});

    final user = await userRepo.getPersonProfileByUserId(userId: myUserId);
    log.fine("MY USER ID: $myUserId, profile: ${user!.profile!.id}");
    log.fine("MY GROUP ID: $widget.groupId");

    final allUsers = await userRepo.getAllMembers();
    profileCache.addAll(allUsers);
    //log.fine(">>> $profileCache");

    if (!mounted) return; // avoid calling setState after dispose

    setState(() => {});
  }

  Person? getProfile(String userId) {
    final person = profileCache[userId];
    //log.fine("===== Found profile for $userId: $person");
    return person;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: StreamBuilder<List<Message>>(
        stream:
            messageRepo.messagesFor(supabase.auth.currentUser!, widget.groupId),
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
                MessageBar(groupId: widget.groupId),
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

class MessageBar extends StatefulWidget {
  const MessageBar({
    super.key,
    //required this.sendFunc,
    required this.groupId,
  });

  //final sendFunc;
  final String groupId;

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
      //color: Colors.grey[200],
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
                  onFieldSubmitted: (value) =>
                      _submitMessage(context, widget.groupId),
                ),
              ),
              ElevatedButton(
                onPressed: () => _submitMessage(context, widget.groupId),
                child: const Text('Send'), // FIXME formatting, text
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
    log.fine('✅ Group ID: $widget.groupId');
    log.fine('✅ To ID: $toId');
    if (text.isEmpty) {
      log.fine('DEBUG: Empty message skipped');
      return;
    }

    log.fine('DEBUG: Sending message from $myUserId to $toId: "$text"');

    _textController.clear();

    log.fine("Sent message from:$myUserId, to:$toId: $text");
    try {
      await MessagesRepository().sendMessage(myUserId, toId, text);
      log.fine('Message sent: $text');
    } on Exception catch (error) {
      log.warning("ERROR: $error");
      //context.showErrorSnackBar(message: error.message); // FIXME - snackbar
    }
    setState(() {});
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.profile,
    required this.myUserId,
  });

  final Message message;
  final Person? profile;
  final String? myUserId;

  @override
  Widget build(BuildContext context) {
    String metaStr = message.fromId != myUserId
        ? "${profile?.givenName} ${profile?.familyName} ${format(message.sentOn)}"
        : format(message.sentOn);

    List<Widget> chatContents = [
      if (message.fromId != myUserId)
        CircleAvatar(
            child: Center(
                child: Icon(
          urgencyIcons[message.urgency],
          color: urgencyColors[message.urgency],
        ))),
      const SizedBox(width: 12),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: urgencyColors[message.urgency],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content, style: TextStyle(color: Colors.white)),
        ),
      ),
      const SizedBox(width: 12),
      Text(metaStr),
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

  static const urgencyColors = {
    MessageUrgency.emergency: Colors.red,
    MessageUrgency.urgent: Colors.purpleAccent,
    MessageUrgency.important: Colors.orange,
    MessageUrgency.normal: Colors.blue,
    "default": Colors.grey,
  };

  static const urgencyIcons = {
    MessageUrgency.emergency: Icons.emergency,
    MessageUrgency.urgent: Icons.explicit_sharp,
    MessageUrgency.important: Icons.label_important,
    MessageUrgency.normal: Icons.mail_rounded,
  };
}
