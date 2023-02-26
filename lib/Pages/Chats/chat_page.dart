// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../Model/chat_model.dart';
import 'chat_room.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  var firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          centerTitle: true,
          title: const Text('Chats',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        body: StreamBuilder(
          stream: firestore
              .collection("chatrooms")
              .where("participants.$userId", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            print('DATA:::${snapshot.hasData}');
            if (snapshot.hasData == true) {
              QuerySnapshot snap = snapshot.data as QuerySnapshot;
              print('DATA:::${snap.docs.length}');
              if (snap.docs.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Center(
                      child: Text(
                        'Your chat list is empty',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Once you start a new conversation, you see it will appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: snap.docs.length,
                  itemBuilder: (context, index) {
                    print(snap.docs.length);
                    ChatModel chat = ChatModel.fromMap(
                        snap.docs[index].data() as Map<String, dynamic>);
                    Map<String, dynamic> participants = chat.participants!;
                    List<String> keys = participants.keys.toList();
                    keys.remove(userId);
                    if (snap.docs.isEmpty) {
                      return const Center(
                        child: Text('No chats yet'),
                      );
                    }

                    log('KEYS:::${keys[0]}');

                    return StreamBuilder(
                      stream: firestore
                          .collection("users")
                          .doc(keys[0])
                          .snapshots(),
                      builder: (context, snapshot) {
                        print('DATA:::${snapshot.data}');
                        if (snapshot.hasData == true) {
                          var userData = snapshot.data as DocumentSnapshot;

                          return ListTile(
                            onTap: () async {
                              var chatRoom =
                                  await getChatRoomMOdel(userData.id);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                            chatModel: chatRoom,
                                            otherId: userData.id,
                                          )));
                            },
                            leading: CircleAvatar(
                              radius: 23,
                              backgroundImage: NetworkImage(userData['image']),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                userData['name'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 1),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.69),
                                    child: Text(
                                      chat.lastMessage as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700]),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 4),
                                  child: Text(
                                    timeago
                                        .format(chat.lastMessageTime.toDate()),
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        } else {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }
                      },
                    );
                  },
                );
              }
            } else if (snapshot.hasData == null) {
              return const Center(child: Text("No data"));
            } else {
              return const Center(child: CupertinoActivityIndicator());
            }
          },
        ));
  }
}
