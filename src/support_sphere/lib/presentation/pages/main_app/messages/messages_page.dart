import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/data/models/chat_group.dart';
import 'package:support_sphere/data/models/generated_classes.dart';
import 'package:support_sphere/data/models/messages.dart';
import 'package:support_sphere/data/models/person.dart';
import 'package:support_sphere/data/repositories/cluster.dart';
import 'package:support_sphere/data/repositories/message.dart';
import 'package:support_sphere/data/repositories/user.dart';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:support_sphere/constants/constants.dart';
import 'package:support_sphere/presentation/components/discreet_button.dart';
import 'package:support_sphere/presentation/components/reauth_dialog.dart';
import 'package:support_sphere/presentation/components/confirm_button.dart';
import 'package:support_sphere/data/repositories/resource.dart';
import 'package:support_sphere/data/repositories/chat_repository.dart';
import 'package:support_sphere/presentation/components/cancel_button.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:timeago/timeago.dart';

const preloader =
    Center(child: CircularProgressIndicator(color: Colors.blueGrey));

final log = Logger('MessagesPage');

class MessagesPage extends StatefulWidget {
  final ChatGroup group;

  const MessagesPage({
    super.key,
    required this.group,
  });

  @override
  State<MessagesPage> createState() => MessagesState(group: group);
}

class MessagesState extends State<MessagesPage> {
  final ChatGroup group;

  final UserRepository userRepo = UserRepository();
  final MessagesRepository messageRepo = MessagesRepository();
  final ClusterRepository clusterRepo = ClusterRepository();

  late final Stream<List<Message>> messagesStream;
  late final Stream<Person?> profileStream;
  final Map<String, Person> profileCache = {};
  late final String myUserId;
  bool? _isCommunicationBlocked;
  bool? _isBlockedByMe;
  ResourceReservations? _pendingReservation;
  int _acceptQuantity = 1;
  final ResourceRepository resourceRepo = ResourceRepository();
  late final String _baseGroupName;
  final ChatRepository chatRepo = ChatRepository();

  MessagesState({required this.group});

  @override
  void initState() {
    log.fine('🚀 initState groupId: "${group.id}"');
    super.initState();

    myUserId = supabase.auth.currentUser!.id;
    _baseGroupName = group.name.replaceFirst(
        RegExp(r' \((Pending|Accepted|Tentative|Rejected|Released|Expired)\)$'), '');
    messagesStream = messageRepo.messagesTo(supabase.auth.currentUser!);
    profileStream = userRepo.personForId(userId: myUserId);
    _loadBlockState();
    _loadPendingReservation();
    _loadInitialData();
  }

  Future<void> _loadBlockState() async {
    if (group.members.length != 2) {
      setState(() {
        _isCommunicationBlocked = false;
        _isBlockedByMe = false;
      });
      return;
    }
    final otherUserId = getOtherUserId();
    final iBlockedOther = await userRepo.isUserBlocking(
      blockerId: myUserId,
      blockeeId: otherUserId,
    );
    final otherBlockedMe = await userRepo.isUserBlocking(
      blockerId: otherUserId,
      blockeeId: myUserId,
    );
    if (!mounted) return;
    setState(() {
      _isBlockedByMe = iBlockedOther;
      _isCommunicationBlocked = iBlockedOther || otherBlockedMe;
    });
  }

  Future<void> _loadPendingReservation() async {
    if (group.members.length != 2 || group.type == GROUP_CHAT_TYPE.chat) return;
    final reservation = await resourceRepo.getPendingReservationForChat(
      groupId: group.id,
    );
    if (!mounted) return;
    setState(() {
      _pendingReservation = reservation;
      _acceptQuantity = reservation?.quantity ?? 1;
    });
  }

  Future<void> _loadInitialData() async {
    log.fine('✅ Group ID: ${group.id}');
    log.fine('✅ My User: $myUserId');
    setState(() => {});
    final user = await userRepo.getPersonProfileByUserId(userId: myUserId);
    log.fine("MY USER ID: $myUserId, profile: ${user!.profile!.id}");
    log.fine("MY GROUP ID: $group.id");
    final allUsers = await userRepo.getAllMembers();
    profileCache.addAll(allUsers);
    // mark all messages read
    await messageRepo.markMessagesRead(group.id, myUserId);
    if (!mounted) return;
    setState(() => {});
  }

  Person? getProfile(String userId) {
    final person = profileCache[userId];
    return person;
  }

  String getOtherUserId() {
    return group.members.first != myUserId
        ? group.members.first
        : group.members.last;
  }

  Color get _appBarColor {
    return switch (_pendingReservation?.status) {
      RESERVATION_STATUS.tentative => ColorConstants.tentativeGreen,
      RESERVATION_STATUS.accepted => ColorConstants.confirmGreen,
      RESERVATION_STATUS.rejected => ColorConstants.rejectedGray,
      RESERVATION_STATUS.released => ColorConstants.cancelGray,
      RESERVATION_STATUS.expired => ColorConstants.cancelGray,
      _ => Colors.white,
    };
  }

  String _groupNameWithStatus(RESERVATION_STATUS? status) {
    if (status == null) return _baseGroupName;
    final suffix = switch (status) {
      RESERVATION_STATUS.pending   => MessagesStrings.statusPending,
      RESERVATION_STATUS.tentative => MessagesStrings.statusTentative,
      RESERVATION_STATUS.accepted  => MessagesStrings.statusAccepted,
      RESERVATION_STATUS.rejected  => MessagesStrings.statusRejected,
      RESERVATION_STATUS.released  => MessagesStrings.statusReleased,
      RESERVATION_STATUS.expired   => MessagesStrings.statusExpired,
    };
    return '$_baseGroupName ($suffix)';
  }

  String get _groupTitle => _groupNameWithStatus(_pendingReservation?.status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarColor,
        title: Text(_groupTitle),
        actions: [
          if (_pendingReservation != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pendingReservation!.status !=
                      RESERVATION_STATUS.accepted) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _acceptQuantity > 1
                              ? () => setState(() => _acceptQuantity--)
                              : null,
                        ),
                        Text('$_acceptQuantity',
                            style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              _acceptQuantity < _pendingReservation!.quantity
                                  ? () => setState(() => _acceptQuantity++)
                                  : null,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  CancelButton(
                    label: MessagesStrings.rejectRequest,
                    onPressed: () async {
                      await resourceRepo.updateReservation(
                        reservationId: _pendingReservation!.id,
                        status: RESERVATION_STATUS.rejected,
                      );
                      await chatRepo.updateGroupName(
                        groupId: group.id,
                        name: _groupNameWithStatus(RESERVATION_STATUS.rejected),
                      );
                      await messageRepo.sendMessage(
                        fromProfileId: myUserId,
                        groupId: group.id,
                        text: MessagesStrings.rejectMessage(
                            _pendingReservation!.quantity),
                        urgency: MESSAGEURGENCY.normal,
                      );
                      if (!mounted) return;
                      setState(() {
                        _pendingReservation = _pendingReservation!.copyWith(
                          status: RESERVATION_STATUS.rejected,
                        );
                      });
                    },
                  ),
                  if (_pendingReservation!.status !=
                      RESERVATION_STATUS.tentative) ...[
                    const SizedBox(width: 8),
                    ConfirmButton(
                      label: MessagesStrings.tentativeAccept,
                      color: ColorConstants.tentativeGreen,
                      onPressed: () async {
                        final originalQty = _pendingReservation!.quantity;
                        final reservationId = _pendingReservation!.id;
                        await resourceRepo.updateReservation(
                          reservationId: reservationId,
                          status: RESERVATION_STATUS.tentative,
                          quantity: _acceptQuantity,
                        );
                        await chatRepo.updateGroupName(
                          groupId: group.id,
                          name: _groupNameWithStatus(RESERVATION_STATUS.tentative),
                        );
                        await messageRepo.sendMessage(
                          fromProfileId: myUserId,
                          groupId: group.id,
                          text: MessagesStrings.tentativeAcceptMessage(
                              _acceptQuantity, originalQty),
                          urgency: MESSAGEURGENCY.normal,
                        );
                        if (!mounted) return;
                        setState(() {
                          _pendingReservation = _pendingReservation!.copyWith(
                            status: RESERVATION_STATUS.tentative,
                            quantity: _acceptQuantity,
                          );
                        });
                      },
                    ),
                  ],
                  if (_pendingReservation!.status !=
                      RESERVATION_STATUS.accepted) ...[
                    const SizedBox(width: 8),
                    ConfirmButton(
                      label: MessagesStrings.acceptRequest,
                      onPressed: () async {
                        final originalQty = _pendingReservation!.quantity;
                        final reservationId = _pendingReservation!.id;
                        await resourceRepo.updateReservation(
                          reservationId: reservationId,
                          status: RESERVATION_STATUS.accepted,
                          quantity: _acceptQuantity,
                        );
                        await chatRepo.updateGroupName(
                          groupId: group.id,
                          name: _groupNameWithStatus(RESERVATION_STATUS.accepted),
                        );
                        await messageRepo.sendMessage(
                          fromProfileId: myUserId,
                          groupId: group.id,
                          text: MessagesStrings.acceptMessage(
                              _acceptQuantity, originalQty),
                          urgency: MESSAGEURGENCY.normal,
                        );
                        if (!mounted) return;
                        setState(() {
                          _pendingReservation = _pendingReservation!.copyWith(
                            status: RESERVATION_STATUS.accepted,
                            quantity: _acceptQuantity,
                          );
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          if (group.members.length == 2 && _isBlockedByMe != null)
            DiscreetButton(
              label: _isBlockedByMe!
                  ? MessagesStrings.unblock
                  : MessagesStrings.block,
              onPressed: () async {
                if (await ReauthDialog(context).perform(AuthService())) {
                  if (_isBlockedByMe!) {
                    await userRepo.unblockUser(
                      blockerId: myUserId,
                      blockeeId: getOtherUserId(),
                    );
                    if (!mounted) return;
                    setState(() {
                      _isBlockedByMe = false;
                      _isCommunicationBlocked = false;
                    });
                  } else {
                    await userRepo.blockUser(
                      blockerId: myUserId,
                      blockeeId: getOtherUserId(),
                    );
                    if (!mounted) return;
                    setState(() {
                      _isBlockedByMe = true;
                      _isCommunicationBlocked = true;
                    });
                  }
                }
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: messageRepo.messagesFor(supabase.auth.currentUser!, group.id),
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
                if (_isCommunicationBlocked == true)
                  Text(MessagesStrings.blockedCommunication)
                else if (_isCommunicationBlocked == false)
                  MessageBar(groupId: group.id),
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

extension on MESSAGEURGENCY {
  Color get color {
    switch (this) {
      case MESSAGEURGENCY.normal:
        return Colors.blue;
      case MESSAGEURGENCY.important:
        return Colors.orange;
      case MESSAGEURGENCY.urgent:
        return Colors.purpleAccent;
      case MESSAGEURGENCY.emergency:
        return Colors.red;
    }
  }
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
                  onFieldSubmitted: (value) => _submitMessage(
                    context,
                    widget.groupId,
                    urgency,
                  ),
                ),
              ),
              ConfirmButton(
                label: 'Send',
                icon: const Icon(Icons.chat),
                onPressed: () => _submitMessage(
                  context,
                  widget.groupId,
                  urgency,
                ),
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
                        child: Text(
                          v.name,
                          style: TextStyle(color: v.color),
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  color: urgency.color,
                  child: Icon(Icons.alarm),
                ),
              )
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
    final amSender = message.fromId == myUserId;
    String metaStr = message.fromId != myUserId
        ? "${profile?.givenName} ${profile?.familyName} ${format(message.sentOn)}"
        : format(message.sentOn);

    List<Widget> chatContents = [
      if (message.fromId != myUserId)
        CircleAvatar(
            child: Text(profile?.givenName.isNotEmpty == true
                ? profile!.givenName[0].toUpperCase()
                : '?')),
      const SizedBox(width: 12),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: amSender ? Colors.grey : message.urgency.color,
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
}
