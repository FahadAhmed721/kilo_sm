import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/messages/message_repo.dart';
import 'package:kiloi_sm/repos/messages/msg_content.dart';

class MessageRepoImpl implements MessageRepo {
  static String messageTable = "message";
  final db = FirebaseFirestore.instance;
  @override
  Stream<QuerySnapshot<Msgcontent>> getInitialMessages() {
    return db
        .collection(messageTable)
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (msgContent, options) => msgContent.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(15)
        .snapshots();
  }

  @override
  Future<QuerySnapshot<Msgcontent>> loadMoreMessages(
      {required Timestamp lastTime}) async {
    return await db
        .collection(messageTable)
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (msg, option) => msg.toFirestore())
        .orderBy("addtime", descending: true)
        .where("addtime", isLessThan: lastTime)
        .limit(15)
        .get();
  }
}
