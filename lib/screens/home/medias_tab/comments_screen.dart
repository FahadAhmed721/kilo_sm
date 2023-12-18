import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/products_provider.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/products/comments.dart';
import 'package:kiloi_sm/repos/products/product_repo.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CommentsScreen extends StatelessWidget {
  static const String routeName = "/comments_screen";
  MediaContent mediaContent;
  CommentsScreen({required this.mediaContent, super.key});

  // @override
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_ScreenNotifier>(
        create: (context) =>
            _ScreenNotifier(mediaContent: mediaContent, context: context),
        builder: (context, _) {
          var screenProvider =
              Provider.of<_ScreenNotifier>(context, listen: false);
          return Consumer2<AuthProvider, _ScreenNotifier>(
              builder: (context, authNotifier, screenNotifier, _) {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Column(
                          children: [
                            ProductsWidget(
                              category: "",
                              price: "",
                              title: mediaContent.title!,
                              url: mediaContent.image!,
                              shouldShowPC: false,
                            ),
                            Expanded(
                              child: ListView.builder(
                                  controller: screenProvider.scrollController,
                                  itemCount: screenNotifier.commentsList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${screenNotifier.commentsList[index].name}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                          Container(
                                            // height: 20,

                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColors.fieldBorderColor,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Text(
                                              "${screenNotifier.commentsList[index].comment}",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 20,
                        right: 20,
                        // top: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,

                          // padding: const EdgeInsets.only(bottom: 10, top: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // color: AppColors.fieldBorderColor,
                              border: Border.all(color: Colors.grey)),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: screenProvider.commentController,
                                  keyboardType: TextInputType.multiline,
                                  autofocus: false,
                                  // focusNode: chatProvider.messageFocusNode,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),

                                  // onTapOutside: (event) {

                                  //   FocusManager
                                  //     .instance.primaryFocus
                                  //     ?.unfocus();},
                                  decoration: const InputDecoration(
                                      hintText: "Type your comment here",
                                      hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                      contentPadding: EdgeInsets.only(
                                          left: 15, top: 0, bottom: 0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent))),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await screenProvider.uploadComment(
                                      authNotifier, context);
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: AppColors.appThemeColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    size: 26,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  MediaContent mediaContent;

  _ScreenNotifier({required this.mediaContent, required context}) {
    loadComments();

    scrollController.addListener(() {
      if (scrollController.offset + 20 >=
          scrollController.position.maxScrollExtent) {
        asyncLoadMoreData(mediaContent.docId!, commentsList.last.addtime!);
      }
    });
  }

  TextEditingController commentController = TextEditingController();
  ScrollController scrollController = ScrollController();
  ProductRepo productRepo = ProductRepo.instance();
  late StreamSubscription<QuerySnapshot<Comment>> listener;
  List<Comment> commentsList = [];

  Future<void> asyncLoadMoreData(
    String id,
    Timestamp lastTime,
  ) async {
    // loadMore = true;
    QuerySnapshot<Comment> tempCommentsList =
        await productRepo.loadMoreUserComments(docId: id, lastTime: lastTime);

    if (tempCommentsList.docs.isNotEmpty) {
      tempCommentsList.docs.forEach((element) {
        bool hasAlreadyPresent =
            commentsList.any((media) => media.id == element.data().id);
        if (!hasAlreadyPresent) {
          commentsList.add(element.data());
        }
      });
      kPrint("new comment ${tempCommentsList.docs.length}");
      notifyListeners();
    }
    // loadMore = false;
    // notifyListeners();
  }

  loadComments() {
    commentsList.clear();
    List<Comment> tempMsgList = <Comment>[];
    final comments = productRepo.getMediaComments(docId: mediaContent.docId!);

    listener = comments.listen((event) {
      // tempMsgList.clear();
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:

            // Handle If you add any new doc in firebase.
            if (change.doc.data() != null) {
              final msg = change.doc.data();
              if (msg != null && !commentsList.any((m) => m.id == msg.id)) {
                commentsList.add(msg);
                kPrint("new comment ${commentsList.length} ${msg.docId}");
              }
              // kPrint("new message ${event.docChanges.length}");
              // tempMsgList.add(change.doc.data()!);
            }

            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
      commentsList.sort((a, b) => b.addtime!.compareTo(a.addtime!));

      // if (scrollController.hasClients) {
      //   print("messagescroll controller");
      //   scrollController.position.animateTo(
      //       // points to the very top of your list
      //       // lowest index // 0
      //       // minScrollExtent or maxScrollExtent works together with reverse proporty of a Custom ScrollView or any Scroll view
      //       scrollController.position.minScrollExtent,
      //       duration: const Duration(milliseconds: 300),
      //       curve: Curves.easeOut);
      // }
      notifyListeners();
    });
  }

  uploadComment(AuthProvider authNotifier, context) async {
    String uid = const Uuid().v4();
    String uidWithoutDashes = uid.replaceAll('-', '');
    kPrint("uid $uidWithoutDashes");
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false);
    try {
      Comment comment = Comment(
        addtime: Timestamp.now(),
        id: uidWithoutDashes,
        docId: mediaContent.docId,
        name: authNotifier.getUserContent.name,
        comment: commentController.text,
      );

      await productRepo.postComment(comment: comment);
      commentController.clear();
      // kPrint("new comment is ${mediaContent.docId!} ${value.id}");
      // await productRepo.updateComment(
      //     mediaDocId: mediaContent.docId!, docId: value.id);

      EasyLoading.dismiss();

      // Navigator.of(context).pop();
    } catch (error) {
      kPrint("exception $error");
      EasyLoading.dismiss();
      // Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
