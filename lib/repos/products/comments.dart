import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? id;
  String? docId;
  String? comment;
  String? name;
  final Timestamp? addtime;

  Comment({this.id, this.comment, this.addtime, this.docId, this.name});

  factory Comment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Comment(
        id: data?['id'],
        comment: data?['comment'],
        addtime: data?['addtime'],
        name: data?['name'],
        docId: data?["docId"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (comment != null) "comment": comment,
      if (docId != null) "docId": docId,
      if (name != null) "name": name,
      if (addtime != null) "addtime": addtime,
    };
  }
}
