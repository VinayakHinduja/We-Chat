// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../api/apis.dart';
import '../main.dart';

import 'package:we_chat/screens/screens.dart';
import 'package:we_chat/helpers/helpers.dart';
import 'package:we_chat/models/models.dart';
import 'package:we_chat/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  late TextEditingController _textController;

  bool _showEmoji = false;

  bool _uploading = false;

  bool _paused = false;

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
          setState(() => _paused = true);
        }
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
          setState(() => _paused = false);
        }
        if (message.toString().contains('inactive')) {
          APIs.updateActiveStatus(false);
          setState(() => _paused = true);
        }
        if (message.toString().contains('detached')) {
          APIs.updateActiveStatus(false);
          setState(() => _paused = true);
        }
      }
      return Future.value(message);
    });
  }

  @override
  void dispose() {
    SystemChannels.lifecycle
        .setMessageHandler((message) => Future.value(message));
    _textController.dispose();
    super.dispose();
  }

  void change() => setState(() => _showEmoji = !_showEmoji);

  _willpop() {
    if (_showEmoji) change();
  }

  @override
  Widget build(BuildContext context) {
    chatMq = MediaQuery.of(context).size;

    return SafeArea(
      child: PopScope(
        canPop: !_showEmoji,
        onPopInvoked: (_) => _willpop(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: const Color.fromARGB(255, 221, 245, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (ctx, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: Text(
                            'Loading ...',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black54,
                            ),
                          ),
                        );

                      // if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: chatMq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (ctx, i) => MessageCard(
                              message: _list[i],
                              pause: _paused,
                            ),
                          );
                        } else {
                          return Center(
                            child: TextButton(
                              onPressed: _sending
                                  ? null
                                  : () async {
                                      setState(() => _sending = true);

                                      await APIs.sendFirstMessage(
                                          widget.user, 'Hii! 👋', Type.text);

                                      setState(() => _sending = false);
                                    },
                              child: const Text(
                                'Say Hii! 👋',
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              if (_uploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _chatInput(),
              if (_showEmoji)
                SizedBox(
                  height: chatMq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      // checkPlatformCompatibility: false,
                      bottomActionBarConfig: const BottomActionBarConfig(
                        showBackspaceButton: false,
                        backgroundColor: Color(0xFFEBEFF2),
                        buttonColor: Color(0xFFEBEFF2),
                        buttonIconColor: Colors.blue,
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: Colors.grey.shade100,
                        buttonIconColor: Colors.black,
                      ),
                      categoryViewConfig: const CategoryViewConfig(
                        showBackspaceButton: true,
                        tabBarHeight: 50,
                      ),
                      emojiTextStyle: const TextStyle(
                        // fontFamily: fonFam,
                        color: Colors.black,
                      ),
                      emojiViewConfig: EmojiViewConfig(
                        columns: 9,
                        recentsLimit: 50,
                        verticalSpacing: 1,
                        emojiSizeMax: 31 * (Platform.isIOS ? 1.30 : 1.0),
                        loadingIndicator: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return StreamBuilder(
      stream: APIs.getUserInfo(widget.user),
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;
        final list =
            data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfileScreen(user: widget.user),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(chatMq.height * .3),
                child: CachedNetworkImage(
                  fit: chatMq.width <= 500 ? BoxFit.fill : null,
                  height: chatMq.width <= 500
                      ? chatMq.height * .045
                      : chatMq.height * .035,
                  width: chatMq.width <= 500
                      ? chatMq.height * .045
                      : chatMq.height * .035,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  errorWidget: (c, url, e) => Image.asset(personPng),
                  placeholder: (c, url) => const Icon(
                    size: 30,
                    CupertinoIcons.person,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtill.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive,
                              )
                        : MyDateUtill.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: chatMq.height * .01, horizontal: chatMq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  SizedBox(width: chatMq.width * .01),
                  IconButton(
                    onPressed: () {
                      if (FocusManager.instance.primaryFocus!.hasFocus)
                        FocusManager.instance.primaryFocus?.unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_rounded,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      // style: const TextStyle(fontFamily: fonFam),
                      autofocus: false,
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () => _showEmoji
                          ? setState(() => _showEmoji = !_showEmoji)
                          : null,
                      decoration: const InputDecoration(
                        hintText: 'Type Something ...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final List<XFile> images =
                          await ImagePicker().pickMultiImage(imageQuality: 60);
                      if (images.isNotEmpty)
                        for (var i in images) {
                          setState(() => _uploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _uploading = false);
                        }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final image = await ImagePicker().pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image == null) return;
                      setState(() => _uploading = true);
                      await APIs.sendChatImage(widget.user, File(image.path));
                      setState(() => _uploading = false);
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: chatMq.width * .01),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          MaterialButton(
            onPressed: _sending
                ? null
                : () async {
                    if (_textController.text.isNotEmpty) {
                      setState(() => _sending = true);
                      if (_list.isEmpty) {
                        await APIs.sendFirstMessage(
                            widget.user, _textController.text, Type.text);
                      } else {
                        await APIs.sendMessage(
                            widget.user, _textController.text, Type.text);
                      }
                      _textController.clear();
                      setState(() => _sending = false);
                    }
                  },
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 15,
              left: 15,
              right: 10,
            ),
            minWidth: 0,
            disabledElevation: 0,
            color: Colors.green,
            shape: const CircleBorder(),
            disabledColor: Colors.grey,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
