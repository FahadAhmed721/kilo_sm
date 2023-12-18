import 'package:cloud_firestore/cloud_firestore.dart';

class MediaContent {
  String? id;
  String? docId;
  String? mediaType;
  String? image;
  String? video;
  String? document;
  String? links;
  String? title;
  final Timestamp? addtime;

  MediaContent(
      {this.id,
      this.mediaType,
      this.image,
      this.video,
      this.document,
      this.addtime,
      this.links,
      this.docId,
      this.title});

  factory MediaContent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MediaContent(
        id: data?['id'],
        docId: data?["docId"],
        mediaType: data?['mediaType'],
        image: data?['image'],
        video: data?["video"],
        document: data?["document"],
        addtime: data?['addtime'],
        links: data?['link'],
        title: data?["title"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (docId != null) "docId": docId,
      if (mediaType != null) "mediaType": mediaType,
      if (image != null) "image": image,
      if (video != null) "video": video,
      if (document != null) "document": document,
      if (title != null) "title": title,
      if (addtime != null) "addtime": addtime,
      if (links != null) "link": links
    };
  }
}
