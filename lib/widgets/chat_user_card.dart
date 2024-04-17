import 'package:flutter/material.dart';

import '../main.dart';
import '../api/apis.dart';

import 'package:we_chat/screens/screens.dart';
import 'package:we_chat/helpers/helpers.dart';
import 'package:we_chat/models/models.dart';
import 'package:we_chat/widgets/widgets.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          EdgeInsets.symmetric(horizontal: mobileMq.width * .03, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user))),
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              //user profile picture
              leading: InkWell(
                onTap: () => showDialog(
                    context: context,
                    builder: (_) => ProfileDialogue(user: widget.user)),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      foregroundImage: provider(),
                    ),
                    if (widget.user.isOnline)
                      Positioned(right: 0, bottom: 0, child: greenCircle()),
                  ],
                ),
              ),

              //user name
              title: Text(widget.user.name),

              //last message
              subtitle: _message != null
                  ? _message!.type == Type.image
                      ? _message!.fromId == APIs.user.uid
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                doubleTickIcon(),
                                const SizedBox(width: 7),
                                const Icon(Icons.image_rounded,
                                    color: Colors.black38, size: 20),
                                text(' Photo'),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.image_rounded,
                                    color: Colors.black38, size: 20),
                                text(' Photo'),
                              ],
                            )
                      : _message!.fromId == APIs.user.uid
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                doubleTickIcon(),
                                const SizedBox(width: 7),
                                // actual msg
                                Flexible(
                                  child: Text(
                                    _message!.msg,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          : text(_message!.msg)
                  : text(widget.user.about),

              //last message time
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ? greenCircle()
                      : text(MyDateUtill.getLastMessageTime(
                          context, _message!.sent)),
            );
          },
        ),
      ),
    );
  }

  ImageProvider? provider() {
    if (widget.user.image.isEmpty) return const AssetImage(personPng);
    if (widget.user.image.isNotEmpty) return NetworkImage(widget.user.image);
    return const AssetImage(personPng);
  }

  Widget text(String text) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget doubleTickIcon() {
    return Icon(
      Icons.done_all_rounded,
      color: _message!.read.isEmpty ? Colors.black38 : Colors.blue,
      size: 20,
    );
  }

  Widget greenCircle() {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.lightGreenAccent[400]),
    );
  }
}
