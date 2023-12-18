import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo.dart';

class MediasProvider extends ChangeNotifier {
  List<MediaContent> imagesList = [];
  List<MediaContent> documentsList = [];
  List<MediaContent> videosList = [];
  List<MediaContent> linksList = [];

  MediaRepo mediaRepo = MediaRepo.instance();

  void callNotifier() {
    notifyListeners();
  }

  clearLists() {
    imagesList.clear();
    videosList.clear();
    documentsList.clear();
    linksList.clear();
  }

  late StreamController<List<MediaContent>> _mediaController;
  late StreamSubscription<QuerySnapshot<MediaContent>> mediaStreamSubscription;

  Stream<List<MediaContent>> getImagesMedia(String id, bool isAdmin) async* {
    kPrint("image is $isAdmin");
    try {
      _mediaController = StreamController<List<MediaContent>>();
      Stream<QuerySnapshot<MediaContent>> result = isAdmin
          ? mediaRepo.getAdminMedia(id: id, mediaType: "image")
          // mediaRepo.getMediaImages(id: id)
          : mediaRepo.getUserMedia(mediaType: "image");

      mediaStreamSubscription = result.listen((event) async {
        // imagesList.clear();
        List<MediaContent> tempList = [];
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              if (change.doc.data() != null) {
                bool hasAlreadyPresent = imagesList.any(
                    (element) => element.image == change.doc.data()!.image);
                if (!hasAlreadyPresent) {
                  tempList.add(change.doc.data()!);
                }
              }
              break;
            case DocumentChangeType.modified:
              if (change.doc.data() != null) {
                // Find and update the existing MediaContent in imagesList
                final index = imagesList.indexWhere(
                    (element) => element.image == change.doc.data()!.image);
                if (index != -1) {
                  imagesList[index] = change.doc.data()!;
                }
              }
              break;
            case DocumentChangeType.removed:
              // Handle if you deleted any doc in Firebase.
              break;
          }
        }
        tempList.reversed.forEach((element) {
          imagesList.insert(0, element);
        });
        // imagesList.addAll(tempList.reversed);
        _mediaController.sink.add(imagesList);
      });
      notifyListeners();
      yield* _mediaController.stream;
    } catch (error) {
      // setError(defaultErrorMessage);
      _mediaController.close(); // Close the controller in case of an error
      yield* Stream.error(error); // Return an error stream
    }
  }

  late StreamController<List<MediaContent>> _mediaDocController;
  late StreamSubscription<QuerySnapshot<MediaContent>>
      mediaDocStreamSubscription;

  Stream<List<MediaContent>> getMediaDocs(String id, bool isAdmin) async* {
    try {
      _mediaDocController = StreamController<List<MediaContent>>();
      Stream<QuerySnapshot<MediaContent>> result = isAdmin
          ? mediaRepo.getAdminMedia(id: id, mediaType: "document")
          // mediaRepo.getMediaDocs(id: id)
          : mediaRepo.getUserMedia(mediaType: "document");

      mediaDocStreamSubscription = result.listen((event) async {
        // documentsList.clear();
        List<MediaContent> tempList = [];
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              if (change.doc.data() != null) {
                kPrint("my data is");
                bool hasAlreadyPresent = documentsList.any((element) =>
                    element.document == change.doc.data()!.document);
                if (!hasAlreadyPresent) {
                  tempList.add(change.doc.data()!);
                }
              }
              break;
            case DocumentChangeType.modified:
              // Handle if you updated any doc in Firebase.
              break;
            case DocumentChangeType.removed:
              // Handle if you deleted any doc in Firebase.
              break;
          }
        }
        tempList.reversed.forEach((element) {
          documentsList.insert(0, element);
        });

        _mediaDocController.sink.add(documentsList);
      });
      notifyListeners();
      yield* _mediaDocController.stream;
    } catch (error) {
      // setError(defaultErrorMessage);
      _mediaDocController.close(); // Close the controller in case of an error
      yield* Stream.error(error); // Return an error stream
    }
  }

  late StreamController<List<MediaContent>> _mediaVideoController;
  late StreamSubscription<QuerySnapshot<MediaContent>>
      mediaVideoStreamSubscription;

  Stream<List<MediaContent>> getVideosMedia(String id, bool isAdmin) async* {
    try {
      _mediaVideoController = StreamController<List<MediaContent>>();
      Stream<QuerySnapshot<MediaContent>> result = isAdmin
          ? mediaRepo.getAdminMedia(id: id, mediaType: "video")
          // mediaRepo.getMediaVideos(id: id)
          : mediaRepo.getUserMedia(mediaType: "video");

      mediaVideoStreamSubscription = result.listen((event) async {
        // documentsList.clear();
        List<MediaContent> tempList = [];
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              if (change.doc.data() != null) {
                kPrint("my data is");
                bool hasAlreadyPresent = videosList.any(
                    (element) => element.video == change.doc.data()!.video);
                if (!hasAlreadyPresent) {
                  tempList.add(change.doc.data()!);
                }
              }
              break;
            case DocumentChangeType.modified:
              // Handle if you updated any doc in Firebase.
              break;
            case DocumentChangeType.removed:
              // Handle if you deleted any doc in Firebase.
              break;
          }
        }
        tempList.reversed.forEach((element) {
          videosList.insert(0, element);
        });

        _mediaVideoController.sink.add(videosList);
      });
      notifyListeners();
      yield* _mediaVideoController.stream;
    } catch (error) {
      // setError(defaultErrorMessage);
      _mediaVideoController.close(); // Close the controller in case of an error
      yield* Stream.error(error); // Return an error stream
    }
  }

  late StreamController<List<MediaContent>> _mediaLinksController;
  late StreamSubscription<QuerySnapshot<MediaContent>>
      mediaLinksStreamSubscription;

  Stream<List<MediaContent>> getLinksMedia(String id, bool isAdmin) async* {
    try {
      _mediaLinksController = StreamController<List<MediaContent>>();
      Stream<QuerySnapshot<MediaContent>> result = isAdmin
          ? mediaRepo.getAdminMedia(id: id, mediaType: "link")
          : mediaRepo.getUserMedia(mediaType: "link");

      mediaLinksStreamSubscription = result.listen((event) async {
        // documentsList.clear();
        List<MediaContent> tempList = [];
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              if (change.doc.data() != null) {
                kPrint("my data is");
                bool hasAlreadyPresent = linksList.any(
                    (element) => element.links == change.doc.data()!.links);
                if (!hasAlreadyPresent) {
                  tempList.add(change.doc.data()!);
                }
              }
              break;
            case DocumentChangeType.modified:
              // Handle if you updated any doc in Firebase.
              break;
            case DocumentChangeType.removed:
              // Handle if you deleted any doc in Firebase.
              break;
          }
        }
        tempList.reversed.forEach((element) {
          linksList.insert(0, element);
        });

        _mediaLinksController.sink.add(linksList);
      });
      notifyListeners();
      yield* _mediaLinksController.stream;
    } catch (error) {
      // setError(defaultErrorMessage);
      _mediaLinksController.close(); // Close the controller in case of an error
      yield* Stream.error(error); // Return an error stream
    }
  }

  void disposeMediaStream() {
    kPrint("dispose");
    mediaStreamSubscription.cancel();
    _mediaController.close();
    _mediaDocController.close();
    mediaDocStreamSubscription.cancel();
    mediaVideoStreamSubscription.cancel();
    _mediaVideoController.close();
    _mediaLinksController.close();
    mediaLinksStreamSubscription.cancel();
  }

  @override
  void dispose() {
    kPrint("dispose");

    mediaStreamSubscription.cancel();
    _mediaController.close();
    _mediaDocController.close();
    mediaDocStreamSubscription.cancel();
    super.dispose();
  }
}
