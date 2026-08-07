import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/message_urgency_extension.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/utils/supabase.dart';

final log = Logger('MessageBar');

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
  MESSAGEURGENCY urgency = MESSAGEURGENCY.normal;

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
                      _submitMessage(context, widget.groupId, urgency),
                ),
              ),
              ConfirmButton(
                label: 'Send',
                icon: const Icon(Icons.chat),
                onPressed: () =>
                    _submitMessage(context, widget.groupId, urgency),
              ),
              PopupMenuButton<MESSAGEURGENCY>(
                initialValue: urgency,
                onSelected: (v) => setState(() {
                  urgency = v;
                }),
                itemBuilder: (ctx) => MESSAGEURGENCY.values
                    .map(
                      (v) => PopupMenuItem(
                        value: v,
                        child: Text(v.name, style: TextStyle(color: v.color)),
                      ),
                    )
                    .toList(),
                child: Container(
                  color: urgency.color,
                  child: Icon(Icons.alarm),
                ),
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

  void _submitMessage(
    BuildContext context,
    String toId,
    MESSAGEURGENCY urgency,
  ) async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    log.fine('✅ Group ID: ${widget.groupId}');
    log.fine('✅ To ID: $toId');
    if (text.isEmpty) {
      log.fine('DEBUG: Empty message skipped');
      return;
    }

    log.fine('DEBUG: Sending message from $myUserId to $toId: "$text"');

    _textController.clear();

    log.fine("Sent message from:$myUserId, to:$toId: $text");
    try {
      await MessagesRepository().sendMessage(
        fromProfileId: myUserId,
        groupId: widget.groupId,
        text: text,
        urgency: urgency,
      );
      log.fine('Message sent: $text');
    } on Exception catch (error) {
      log.warning("ERROR: $error");
      //context.showErrorSnackBar(message: error.message); // FIXME - snackbar
    }
    setState(() {});
  }
}
