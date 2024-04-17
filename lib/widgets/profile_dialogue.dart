import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/widgets/constants.dart';

import '../main.dart';

import 'package:we_chat/screens/screens.dart';
import 'package:we_chat/models/models.dart';

class ProfileDialogue extends StatelessWidget {
  const ProfileDialogue({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return mobileMq.width >= 450
        ? AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.white.withOpacity(.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SizedBox(
              height: mobileMq.height * .35,
              width: mobileMq.width * .6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: mobileMq.width * .4,
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.centerRight,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewProfileScreen(user: user),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(mobileMq.height * .25),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        height: mobileMq.height * .24,
                        width: mobileMq.width * .52,
                        imageUrl: user.image,
                        placeholder: (c, url) => const Icon(
                          CupertinoIcons.person,
                          color: Colors.black,
                        ),
                        errorWidget: (c, url, e) => Image.asset(personPng),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.white.withOpacity(.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SizedBox(
              height: mobileMq.height * .38,
              width: mobileMq.width * .6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: mobileMq.width * .4,
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.centerRight,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewProfileScreen(user: user),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(mobileMq.height * .25),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        height: mobileMq.height * .27,
                        width: mobileMq.width * .6,
                        imageUrl: user.image,
                        placeholder: (c, url) => const Icon(
                          CupertinoIcons.person,
                          color: Colors.black,
                        ),
                        errorWidget: (c, url, e) => Image.asset(personPng),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
