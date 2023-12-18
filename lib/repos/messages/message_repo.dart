import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/messages/message_repo_impl.dart';
import 'package:kiloi_sm/repos/messages/msg_content.dart';

mixin MessageRepo {
  static final MessageRepo _instance = MessageRepoImpl();

  static MessageRepo instance() {
    return _instance;
  }

  Stream<QuerySnapshot<Msgcontent>> getInitialMessages();

  Future<QuerySnapshot<Msgcontent>> loadMoreMessages(
      {required Timestamp lastTime});
}
