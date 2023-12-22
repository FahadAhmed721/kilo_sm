import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiloi_sm/components/custom_web_view.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/components/web_view.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo.dart';
import 'package:kiloi_sm/screens/home/medias_tab/documents_tab/user_documents_tab_cell.dart';
import 'package:kiloi_sm/screens/home/medias_tab/upload_media_screen.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  late MediasProvider mediasProvider;
  late AuthProvider authProvider;
  late Stream<StreamSubscription<QuerySnapshot<MediaContent>>> listener;
  late Stream<List<MediaContent>> stream;

  @override
  void initState() {
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    mediasProvider.documentsList.clear();
    stream = fetchMediaDocs();

    super.initState();
  }

  Stream<List<MediaContent>> fetchMediaDocs() async* {
    yield* mediasProvider.getMediaDocs(
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
                      ? UserDocumentsTabCell(
                          documentsList: mediasProvider.documentsList,
                          onDocumentTap: (url, title) =>
                              screenNotifier.onClick(context, url, title),
                          scrollController:
                              screenNotifier.messageScrollController,
                        )
                      : GridView.builder(
                          controller:
                              screenNotifierProvider.messageScrollController,
                          // physics: mediaNotifier.documentsList.length >= 14
                          //     ? AlwaysScrollableScrollPhysics()
                          //     : NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 38, horizontal: 37),
                          itemCount: 1 + mediaNotifier.documentsList.length,
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
                                          .pickFile(context);
                                    },
                                    child: const UploadButton())
                                : GestureDetector(
                                    onTap: () => screenNotifier.onClick(
                                        context,
                                        mediaNotifier
                                            .documentsList[index - 1].document!,
                                        mediaNotifier
                                            .documentsList[index - 1].title!),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.uploadButtonColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Center(
                                        child: Icon(
                                          Icons.edit_document,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                          });
                });
              });
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  final picker = ImagePicker();
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
            authProvider.userToken, mediasProvider.documentsList.last.addtime!);
      }
    });
    // });
  }

  Future<void> pickFile(context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false, // Set to false to pick only one file
          type: FileType.custom,
          allowedExtensions: ['pdf', "doc"]);

      if (result != null) {
        File file = File(result.files.single.path!);
        Navigator.pushNamed(context, UploadMediaScreen.routeName,
            arguments: {"mediaType": "document", "imageFile": file});
        // Do something with the selected file
        kPrint('document file path: ${file.path}');
      } else {
        // User canceled the file picker
        kPrint('File picking canceled');
      }
    } catch (e) {
      kPrint('Error picking file: $e');
    }
  }

  void onClick(context, String url, String title) {
    Navigator.pushNamed(context, WebView.routeName, arguments: {
      "url": "https://docs.google.com/gview?embedded=true&url=$url",
      "appbarTitle": "Document",
      "title": title
    });
  }

  Future<void> asyncLoadMoreData(
    String id,
    Timestamp lastTime,
  ) async {
    loadMore = true;
    QuerySnapshot<MediaContent> docsList = authProvider.getUserContent.isAdmin!
        ? await mediaRepo.loadMoreData(
            id: id, lastTime: lastTime, mediaType: "document")
        : await mediaRepo.loadMoreUserData(
            lastTime: lastTime, mediaType: "document");
    if (docsList.docs.isNotEmpty) {
      docsList.docs.forEach((element) {
        bool hasAlreadyPresent = mediasProvider.documentsList
            .any((media) => media.document == element.data().document);
        if (!hasAlreadyPresent) {
          mediasProvider.documentsList.add(element.data());
        }
      });
      mediasProvider.callNotifier();
    }
    loadMore = false;
    notifyListeners();
  }
}
