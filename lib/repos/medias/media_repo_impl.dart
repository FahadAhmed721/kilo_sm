import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class MediaRepoImpl implements MediaRepo {
  static String mediaTable = "media";
  final db = FirebaseFirestore.instance;
  @override
  Future<String?> uploadImage(File file, {String mediaType = "image"}) async {
    try {
      final uniqueId = const Uuid().v4();
      final storage = FirebaseStorage.instance;
      // Determine the MIME type of the file
      // final mimeType = lookupMimeType(file.path);
      // Extract file extension
      final extension = path.extension(file.path);

      // Set the correct path based on MIME type
      String filePath = mediaType.startsWith('image')
          ? 'images/$uniqueId.png'
          : 'documents$uniqueId$extension';

      Reference ref = storage.ref().child(filePath);

      // if (mediaType == "image") {
      //   ref = storage.ref().child('images/$uniqueId.png');
      // } else if (mediaType == "document") {
      // ref = storage.ref().child(filePath);
      // }

      // Upload the file
      final UploadTask uploadTask = ref.putFile(file);
      // Wait for the upload to complete and get the download URL
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadURL = await ref.getDownloadURL();
        // The download URL of the uploaded image
        return downloadURL;
      } else {
        // Handle the case where the upload was not successful
        return null;
      }
      // The image has been uploaded successfully.
    } catch (e) {
      kPrint("file uploading error $e");
      // Handle errors here.
    }
    return null;
  }

  @override
  Future<DocumentReference> postMediaContent(
      {required MediaContent mediaContent}) async {
    DocumentReference? newDoc;
    await db
        .collection(mediaTable)
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (msgData, option) => mediaContent.toFirestore())
        .add(mediaContent)
        .then((value) {
      newDoc = value;
    });
    return newDoc!;
  }

  @override
  Stream<QuerySnapshot<MediaContent>> getMediaImages(
      {required String id, MediaContent? mediaContent}) {
    return db
        .collection(mediaTable)
        .where("id", isEqualTo: id)
        .where("mediaType", isEqualTo: "image")
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (msgData, option) => msgData.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(14)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<MediaContent>> getMediaDocs(
      {required String id, MediaContent? mediaContent}) {
    return db
        .collection(mediaTable)
        .where("id", isEqualTo: id)
        .where("mediaType", isEqualTo: "document")
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (msgData, option) => mediaContent!.toFirestore())
        .orderBy("addtime", descending: true)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<MediaContent>> getMediaVideos(
      {required String id, MediaContent? mediaContent}) {
    return db
        .collection(mediaTable)
        .where("id", isEqualTo: id)
        .where("mediaType", isEqualTo: "video")
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (msgData, option) => mediaContent!.toFirestore())
        .orderBy("addtime", descending: true)
        .snapshots();
  }

  @override
  Future<QuerySnapshot<MediaContent>> loadMoreData(
      {required String id,
      required Timestamp lastTime,
      required String mediaType}) async {
    final medias = await db
        .collection(mediaTable)
        .where('id', isEqualTo: id)
        .where("mediaType", isEqualTo: mediaType)
        .where("addtime", isLessThan: lastTime)
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (media, option) => media.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(14)
        .get();
    return medias;
  }

  @override
  Future<QuerySnapshot<MediaContent>> loadMoreUserData(
      {required Timestamp lastTime, required String mediaType}) async {
    final medias = await db
        .collection(mediaTable)
        .where("mediaType", isEqualTo: mediaType)
        .where("addtime", isLessThan: lastTime)
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (media, option) => media.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(14)
        .get();
    return medias;
  }

  @override
  Stream<QuerySnapshot<MediaContent>> getUserMedia(
      {required String mediaType}) {
    return db
        .collection(mediaTable)
        .where("mediaType", isEqualTo: mediaType)
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (msgData, option) => msgData.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(14)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<MediaContent>> getAdminMedia(
      {required String id, required String mediaType}) {
    return db
        .collection(mediaTable)
        .where("id", isEqualTo: id)
        .where("mediaType", isEqualTo: mediaType)
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (msgData, option) => msgData.toFirestore())
        .orderBy("addtime", descending: true)
        .snapshots();
  }

  @override
  Future<void> updateMediaContent({required String id}) async {
    await db
        .collection(mediaTable)
        .doc(id)
        .withConverter(
            fromFirestore: MediaContent.fromFirestore,
            toFirestore: (media, option) => media.toFirestore())
        .update({"docId": id});
  }

  // @override
  // Future<QuerySnapshot<MediaContent>> getMediaImages(
  //     {required String id,}) async {
  //   return await db
  //       .collection(mediaTable)
  //       .where("id", isEqualTo: id)
  //       .withConverter(
  //           fromFirestore: MediaContent.fromFirestore,
  //           toFirestore: (msgData, option) => mediaContent.toFirestore())
  //       .get();
  // }
}
