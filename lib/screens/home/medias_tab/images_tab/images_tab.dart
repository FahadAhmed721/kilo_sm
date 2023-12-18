import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';

import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo.dart';
import 'package:kiloi_sm/screens/home/medias_tab/comments_screen.dart';
import 'package:kiloi_sm/screens/home/medias_tab/images_tab/user_images_tab_cell.dart';
import 'package:kiloi_sm/screens/home/medias_tab/upload_media_screen.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ImageTab extends StatefulWidget {
  const ImageTab({super.key});

  @override
  State<ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends State<ImageTab> {
  late MediasProvider mediasProvider;
  late AuthProvider authProvider;
  late Stream<StreamSubscription<QuerySnapshot<MediaContent>>> listener;
  late Stream<List<MediaContent>> stream;

  @override
  void initState() {
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    mediasProvider.imagesList.clear();

    stream = fetchMediaImage();

    super.initState();
  }

  Stream<List<MediaContent>> fetchMediaImage() async* {
    yield* mediasProvider.getImagesMedia(
        authProvider.userToken, authProvider.getUserContent.isAdmin!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => _ScreenNotifier(context),
        builder: (context, _) {
          var screenNotifierProvider =
              Provider.of<_ScreenNotifier>(context, listen: false);
          return StreamBuilder<Object>(
              stream: stream, //fetchMediaImage(context),
              builder: (context, snapshot) {
                return Consumer2<MediasProvider, AuthProvider>(
                    builder: (context, mediaNotifier, authNotifier, _) {
                  // kPrint("isAdmin ${authNotifier.getUserContent.isAdmin}");
                  return !authNotifier.getUserContent.isAdmin!
                      ? UserImageTabCell(
                          imagesList: mediaNotifier.imagesList,
                          scrollController:
                              screenNotifierProvider.messageScrollController)
                      : GridView.builder(
                          controller:
                              screenNotifierProvider.messageScrollController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 38, horizontal: 37),
                          itemCount: 1 + mediaNotifier.imagesList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Number of columns
                            crossAxisSpacing:
                                10, // Horizontal space between items
                            mainAxisSpacing: 10, // Vertical space between items
                          ),
                          itemBuilder: (context, index) {
                            return index == 0
                                ? InkWell(
                                    onTap: () async {
                                      await screenNotifierProvider
                                          .pickImage(context);
                                    },
                                    child: const UploadButton())
                                : CustomImage(
                                    onTap: () =>
                                        screenNotifierProvider.onTapImage(
                                          context,
                                          mediaNotifier.imagesList[index - 1],
                                        ),
                                    url: mediaNotifier
                                            .imagesList[index - 1].image ??
                                        "",
                                    title: mediaNotifier
                                            .imagesList[index - 1].title ??
                                        "");
                          });
                });
              });
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  final picker = ImagePicker();
  MediaRepo mediaRepo = MediaRepo.instance();
  final uniqueId = const Uuid().v4();
  List<MediaContent> imagesList = [];
  bool loadMore = false;
  late MediasProvider mediasProvider;
  late AuthProvider authProvider;
  ScrollController messageScrollController = ScrollController();
  _ScreenNotifier(context) {
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {

    messageScrollController.addListener(() {
      if (messageScrollController.offset + 20 >=
          messageScrollController.position.maxScrollExtent) {
        kPrint("hello");
        asyncLoadMoreData(
            authProvider.userToken, mediasProvider.imagesList.last.addtime!);
      }
    });
    // });
  }

  Future<void> pickImage(context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.pushNamed(context, UploadMediaScreen.routeName, arguments: {
        "mediaType": "image",
        "imageFile": File(pickedFile.path)
      });
    } else {
      // Handle no image selected.
    }
  }

  void onTapImage(
    context,
    MediaContent mediaContent,
  ) {
    kPrint("media Content is ${mediaContent.image}");
    Navigator.pushNamed(context, CommentsScreen.routeName, arguments: {
      "mediaContent": mediaContent,
    });
  }

  Future<void> asyncLoadMoreData(
    String id,
    Timestamp lastTime,
  ) async {
    loadMore = true;
    QuerySnapshot<MediaContent> imagesList =
        authProvider.getUserContent.isAdmin!
            ? await mediaRepo.loadMoreData(
                id: id, lastTime: lastTime, mediaType: "image")
            : await mediaRepo.loadMoreUserData(
                lastTime: lastTime, mediaType: "image");
    kPrint("new images ${imagesList.docs.length}");
    if (imagesList.docs.isNotEmpty) {
      imagesList.docs.forEach((element) {
        bool hasAlreadyPresent = mediasProvider.imagesList
            .any((media) => media.image == element.data().image);
        if (!hasAlreadyPresent) {
          mediasProvider.imagesList.add(element.data());
        }
      });
      mediasProvider.callNotifier();
    }
    loadMore = false;
    // notifyListeners();
  }
}
