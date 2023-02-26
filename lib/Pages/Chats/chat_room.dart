// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_olx/Constant/constants.dart';
import 'package:student_olx/Model/chat_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../Model/message_model.dart';
import '../../Provider/user_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final otherId;

  final ChatModel? chatModel;

  const ChatRoomScreen({Key? key, this.otherId, this.chatModel})
      : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  TextEditingController message = TextEditingController();

  var userId = FirebaseAuth.instance.currentUser!.uid;
  var firestore = FirebaseFirestore.instance;
  Radius messageRadius = const Radius.circular(10);
  var tk;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(widget.otherId);
    Provider.of<UserProvider>(context, listen: false)
        .getNameById(widget.otherId);
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      NetworkImage(userProvider.otherUserImage ?? " "),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(userProvider.otherUserName ?? " ",
                    style: const TextStyle(color: Colors.black)),
              ],
            )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: Column(
              children: [
                Expanded(
                    child: Container(
                  child: StreamBuilder(
                    stream: firestore
                        .collection('chatrooms')
                        .doc(widget.chatModel!.chatRoomId)
                        .collection('messages')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      debugPrint(snapshot.data.toString());
                      QuerySnapshot snap = snapshot.data as QuerySnapshot;
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {}
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: snap.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel messageModel = MessageModel.fromMap(
                                  snap.docs[index].data()
                                      as Map<String, dynamic>);
                              print(snap.docs[index]['seen'].toString());
                              // when chat load set seen to true

                              if (messageModel.sender != userId) {
                                if (snap.docs[index]['seen'] == false) {
                                  firestore
                                      .collection('chatrooms')
                                      .doc(widget.chatModel!.chatRoomId)
                                      .collection('messages')
                                      .doc(snap.docs[index].id)
                                      .update({
                                    'seen': true,
                                  });
                                }
                              } else {
                                print("receiver");
                              }

                              return Column(
                                crossAxisAlignment:
                                    messageModel.sender == userId
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        messageModel.sender == userId
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomRight:
                                                messageModel.sender != userId
                                                    ? messageRadius
                                                    : const Radius.circular(0),
                                            topRight: messageRadius,
                                            bottomLeft: messageRadius,
                                            topLeft:
                                                messageModel.sender == userId
                                                    ? messageRadius
                                                    : const Radius.circular(0),
                                          ),
                                          color: messageModel.sender == userId
                                              ? buttonColor
                                              : buttonColor,
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.005),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.height * 0.015,
                                            vertical: size.height * 0.01),
                                        child: Column(
                                          crossAxisAlignment:
                                              messageModel.sender == userId
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              children: [
                                                GestureDetector(
                                                  onLongPress: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Delete this chat?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            // ignore: deprecated_member_use
                                                            TextButton(
                                                              child: const Text(
                                                                  'Delete'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                deleteMessgae(
                                                                    messageModel
                                                                        .messageId);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    messageModel.text as String,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Text(
                                            //   timeago
                                            //       .format(messageModel.time!),
                                            //   style: const TextStyle(
                                            //       fontSize: 10,
                                            //       color: Colors.white70),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        messageModel.sender == userId
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      messageModel.sender != userId
                                          ? Container()
                                          : Icon(
                                              Icons.done_all,
                                              size: 13,
                                              color: messageModel.seen == true
                                                  ? buttonColor
                                                  : Colors.grey,
                                            ),
                                      SizedBox(width: size.height * 0.01),
                                      Text(
                                        timeago.format(messageModel.time!),
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.black),
                                      ),
                                    ],
                                  )
                                  // Icon(
                                  //   Icons.done_all,
                                  //   size: 13,
                                  //   color: messageModel.seen == true
                                  //       ? Colors.green
                                  //       : Colors.white,
                                  // )
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('{{error}}'),
                          );
                        } else {
                          return const Center(
                            child: Text('{{error}}'),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  // color: buttonColor.withOpacity(0.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            cursorColor: buttonColor,
                            controller: message,
                            maxLines: null,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                                hintText: 'Type a message',
                                hintStyle: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                                helperStyle:
                                    const TextStyle(color: Colors.black),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: buttonColor.withOpacity(0.1),
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      var doc = await firestore
                                          .collection('users')
                                          .doc(widget.otherId)
                                          .get();
                                      // var token = doc.data()!['token'];
                                      sendMessage(userProvider.name);
                                    },
                                    icon: const Icon(
                                      Icons.send_sharp,
                                      color: buttonColor,
                                    ))),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  deleteMessgae(msgid) async {
    await firestore
        .collection('chatrooms')
        .doc(widget.chatModel!.chatRoomId)
        .collection('messages')
        .doc(msgid)
        .delete();
  }

  sendMessage(name) async {
    String msg = message.text.trim();

    if (msg != '') {
      MessageModel messageModel = MessageModel(
        sender: FirebaseAuth.instance.currentUser!.uid,
        messageId: const Uuid().v1(),
        text: msg,
        seen: false,
        time: DateTime.now(),
      );
      firestore
          .collection('chatrooms')
          .doc(widget.chatModel!.chatRoomId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
      widget.chatModel!.lastMessage = msg;
      widget.chatModel!.lastMessageTime = DateTime.now();

      firestore
          .collection('chatrooms')
          .doc(widget.chatModel!.chatRoomId)
          .set(widget.chatModel!.toMap());

      message.clear();
      debugPrint('message sent');
    }
  }
}
