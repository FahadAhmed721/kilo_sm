import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/messages/message_repo.dart';
import 'package:kiloi_sm/repos/messages/msg_content.dart';
import 'package:kiloi_sm/repos/user/user.dart';
import 'package:kiloi_sm/store/user_storage.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  late StreamSubscription<QuerySnapshot<Msgcontent>> listener;
  // ScrollController messageScrollController = ScrollController();
  List<Msgcontent> messagesList = [];
  final db = FirebaseFirestore.instance;
  var chatMessageController = TextEditingController();
  var messageFocusNode = FocusNode();
  MessageRepo messageRepo = MessageRepo.instance();
  UserContent currentUser = UserStorage.instance().getUserContent;

  loadMessages() {
    messagesList.clear();
    List<Msgcontent> tempMsgList = <Msgcontent>[];
    final messages = messageRepo.getInitialMessages();

    listener = messages.listen((event) {
      // tempMsgList.clear();
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:

            // Handle If you add any new doc in firebase.
            if (change.doc.data() != null) {
              kPrint("first time messages");
              final msg = change.doc.data();
              if (msg != null && !messagesList.any((m) => m.id == msg.id)) {
                messagesList.add(msg);
              }
              // kPrint("new message ${event.docChanges.length}");
              // tempMsgList.add(change.doc.data()!);
            }

            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
      messagesList.sort((a, b) => b.addtime!.compareTo(a.addtime!));

      // if (messageScrollController.hasClients) {
      //   print("messagescroll controller");
      //   messageScrollController.position.animateTo(
      //       // points to the very top of your list
      //       // lowest index // 0
      //       // minScrollExtent or maxScrollExtent works together with reverse proporty of a Custom ScrollView or any Scroll view
      //       messageScrollController.position.minScrollExtent,
      //       duration: const Duration(milliseconds: 300),
      //       curve: Curves.easeOut);
      // }
      notifyListeners();
    });
  }

  Future<void> sendMessage(String id, String name) async {
    String messageContent = chatMessageController.text;
    String uid = const Uuid().v4();

    if (messageContent.isEmpty) {
      return;
    }

    Msgcontent msgcontent = Msgcontent(
        token: id,
        content: messageContent,
        type: MessageSecondryType.TEXT.name,
        name: name,
        id: uid,
        addtime: Timestamp.now());

    await db
        .collection("message")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (msgData, option) => msgData.toFirestore())
        .add(msgcontent)
        .then((DocumentReference doc) {
      chatMessageController.clear();
      kPrint("new message doc is ....${doc.id} ");
    });
  }

  Future sendImage() async {
    String uid = const Uuid().v4();
    Msgcontent msgcontent = Msgcontent(
        token: currentUser.token,
        content: "", // here will set image url after uploading
        type: MessageSecondryType.IMAGE.name,
        name: currentUser.name,
        id: uid,
        addtime: Timestamp.now());
    await db
        .collection("message")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (msgData, option) => msgData.toFirestore())
        .add(msgcontent)
        .then((DocumentReference doc) {
      kPrint("new message doc is ....${doc.id} ");
    });
  }

  Future<void> asyncLoadMoreData() async {
    final messages = await messageRepo.loadMoreMessages(
        lastTime: messagesList.last.addtime!);
    if (messages.docs.isNotEmpty) {
      messages.docs.forEach((msg) {
        if (!messagesList.any((m) => m.id == msg.id)) {
          kPrint(
              "new Message are while loading ${messages.docs.length} ${msg.data().id}");
          var data = msg.data();
          messagesList.add(data);
        }
      });
      notifyListeners();
    }
  }

  clearMessages() {
    messagesList.clear();
  }

  clearDataWithDispose() {
    chatMessageController.dispose();
    // messageScrollController.dispose();
  }

  @override
  void dispose() {
    listener.cancel();
    chatMessageController.dispose();
    // messageScrollController.dispose();

    super.dispose();
  }
}

enum MessageSecondryType { TEXT, IMAGE }
