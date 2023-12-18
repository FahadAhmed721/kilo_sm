import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo_impl.dart';

mixin MediaRepo {
  static MediaRepo _instance = MediaRepoImpl();

  static MediaRepo instance() {
    return _instance;
  }

  Future<DocumentReference> postMediaContent(
      {required MediaContent mediaContent});
  Future<void> updateMediaContent({required String id});

  Stream<QuerySnapshot<MediaContent>> getMediaImages(
      {required String id, MediaContent? mediaContent});
  Stream<QuerySnapshot<MediaContent>> getUserMedia({required String mediaType});
  Stream<QuerySnapshot<MediaContent>> getMediaDocs(
      {required String id, MediaContent? mediaContent});
  Stream<QuerySnapshot<MediaContent>> getMediaVideos(
      {required String id, MediaContent? mediaContent});
  Stream<QuerySnapshot<MediaContent>> getAdminMedia(
      {required String id, required String mediaType});
  Future<QuerySnapshot<MediaContent>> loadMoreData(
      {required String id,
      required Timestamp lastTime,
      required String mediaType});

  Future<QuerySnapshot<MediaContent>> loadMoreUserData(
      {required Timestamp lastTime, required String mediaType});
  Future<String?> uploadImage(File file, {String mediaType = "image"});
}
