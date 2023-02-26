import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatModel {
  var chatRoomId;
  var tokenId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  var lastMessageTime;

  ChatModel({
    this.chatRoomId,
    this.participants,
    this.tokenId,
    this.lastMessage,
    this.lastMessageTime,
  });

  ChatModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    tokenId = map['tokenId'];
    lastMessage = map['lastMessage'];
    lastMessageTime = map['lastMessageTime'];

    participants = Map<String, dynamic>.from(map['participants']);
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'tokenId': tokenId,
      'participants': participants,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
    };
  }
}



  Future<ChatModel?> getChatRoomMOdel(otherId) async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;
    ChatModel? chatModel;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(otherId).get();
    final userData = userDoc.data()! as dynamic;
    QuerySnapshot chatRoom = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.$userUid', isEqualTo: true)
        .where('participants.$otherId', isEqualTo: true)
        .get();
    if (chatRoom.docs.isNotEmpty) {
      var docData = chatRoom.docs[0].data() as dynamic;
      ChatModel existing = ChatModel.fromMap(docData as Map<String, dynamic>);
      chatModel = existing;
      log('chatroom found');
    } else {
      ChatModel chatModel = ChatModel(
          lastMessageTime: Timestamp.now(),
          chatRoomId: Uuid().v1(),
          lastMessage: '',
          tokenId: userData['token'],
          participants: {
            otherId: true,
            userUid: true,
          });
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatModel.chatRoomId)
          .set(chatModel.toMap());
      chatModel = chatModel;


      log('chatroom New Chat Room Created');
    }
    return chatModel;
  }
