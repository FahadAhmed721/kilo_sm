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
import 'package:kiloi_sm/screens/home/medias_tab/links_tab/links_user_tab.dart';
import 'package:kiloi_sm/screens/home/medias_tab/upload_media_screen.dart';
import 'package:kiloi_sm/screens/home/medias_tab/videos_tab/user_video_tab_cell.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinksTab extends StatefulWidget {
  const LinksTab({super.key});

  @override
  State<LinksTab> createState() => _LinksTabState();
}

class _LinksTabState extends State<LinksTab> {
  late MediasProvider mediasProvider;
  late AuthProvider authProvider;

  late Stream<List<MediaContent>> stream;

  @override
  void initState() {
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    mediasProvider.linksList.clear();
    stream = fetchMediaLink();

    super.initState();
  }

  Stream<List<MediaContent>> fetchMediaLink() async* {
    yield* mediasProvider.getLinksMedia(
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
                      ? UserLinkTabCell(
                          scrollController:
                              screenNotifier.messageScrollController,
                          linkList: mediaNotifier.linksList,
                        )
                      : GridView.builder(
                          controller:
                              screenNotifierProvider.messageScrollController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 38, horizontal: 37),
                          itemCount: 1 + mediaNotifier.linksList.length,
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
                                            .linksList[index - 1].links!),
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
                                                Icons.link,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (mediaNotifier.linksList[index - 1]
                                            .title!.isNotEmpty)
                                          Text(
                                            mediaNotifier.linksList[index - 1]
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
            authProvider.userToken, mediasProvider.linksList.last.addtime!);
      }
    });
    // });
  }
  onClickUpload(
    context,
  ) {
    Navigator.pushNamed(context, UploadMediaScreen.routeName, arguments: {
      "mediaType": "link",
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
    QuerySnapshot<MediaContent> linkList = authProvider.getUserContent.isAdmin!
        ? await mediaRepo.loadMoreData(
            id: id, lastTime: lastTime, mediaType: "link")
        : await mediaRepo.loadMoreUserData(
            lastTime: lastTime, mediaType: "link");
    if (linkList.docs.isNotEmpty) {
      linkList.docs.forEach((element) {
        bool hasAlreadyPresent = mediasProvider.linksList
            .any((media) => media.links == element.data().links);
        if (!hasAlreadyPresent) {
          mediasProvider.linksList.add(element.data());
        }
      });
      mediasProvider.callNotifier();
    }
    loadMore = false;
    notifyListeners();
  }
}
