import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/components/web_view.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo.dart';
import 'package:kiloi_sm/screens/home/medias_tab/upload_media_screen.dart';
import 'package:kiloi_sm/screens/home/medias_tab/videos_tab/user_video_tab_cell.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  late MediasProvider mediasProvider;
  late AuthProvider authProvider;

  late Stream<List<MediaContent>> stream;

  @override
  void initState() {
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    mediasProvider.videosList.clear();
    stream = fetchMediaVideo();

    super.initState();
  }

  Stream<List<MediaContent>> fetchMediaVideo() async* {
    yield* mediasProvider.getVideosMedia(
        authProvider.userToken, authProvider.getUserContent.isAdmin!);
  }

  @override
  void dispose() {
    // mediasProvider.disposeMediaStream();

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
                return Consumer2<_ScreenNotifier, MediasProvider>(
                    builder: (context, screenNotifier, mediaNotifier, _) {
                  return !authProvider.getUserContent.isAdmin!
                      ? UserVideoTabCell(
                          scrollController:
                              screenNotifier.messageScrollController,
                          videosList: mediaNotifier.videosList,
                        )
                      : GridView.builder(
                          controller:
                              screenNotifierProvider.messageScrollController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 38, horizontal: 37),
                          itemCount: 1 + mediaNotifier.videosList.length,
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
                                    onTap: () =>
                                        screenNotifier.onClickUpload(context),
                                    child: const UploadButton())
                                : InkWell(
                                    onTap: () => screenNotifier.launchURL(
                                        mediaNotifier
                                            .videosList[index - 1].video!),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColors.uploadButtonColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          mediaNotifier.videosList[index - 1]
                                                  .title ??
                                              "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  );
                          });
                });
              });
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  MediaRepo mediaRepo = MediaRepo.instance();
  bool loadMore = false;
  late MediasProvider mediasProvider;
  late AuthProvider authProvider;
  ScrollController messageScrollController = ScrollController();
  _ScreenNotifier(context) {
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {

    authProvider = Provider.of<AuthProvider>(context, listen: false);
    messageScrollController.addListener(() {
      if (messageScrollController.offset + 20 >=
          messageScrollController.position.maxScrollExtent) {
        asyncLoadMoreData(
            authProvider.userToken, mediasProvider.videosList.last.addtime!);
      }
    });
    // });
  }
  onClickUpload(
    context,
  ) {
    Navigator.pushNamed(context, UploadMediaScreen.routeName, arguments: {
      "mediaType": "video",
    });
  }

  void onClickVideo(context, String url) {
    kPrint("url is $url");
    Navigator.pushNamed(context, WebView.routeName,
        arguments: {"url": url, "appbarTitle": ""});
  }

  void launchURL(url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {}
  }

  Future<void> asyncLoadMoreData(
    String id,
    Timestamp lastTime,
  ) async {
    loadMore = true;
    QuerySnapshot<MediaContent> videoList = authProvider.getUserContent.isAdmin!
        ? await mediaRepo.loadMoreData(
            id: id, lastTime: lastTime, mediaType: "video")
        : await mediaRepo.loadMoreUserData(
            lastTime: lastTime, mediaType: "video");
    if (videoList.docs.isNotEmpty) {
      videoList.docs.forEach((element) {
        bool hasAlreadyPresent = mediasProvider.videosList
            .any((media) => media.video == element.data().video);
        if (!hasAlreadyPresent) {
          mediasProvider.videosList.add(element.data());
        }
      });
      mediasProvider.callNotifier();
    }
    loadMore = false;
    notifyListeners();
  }
}
