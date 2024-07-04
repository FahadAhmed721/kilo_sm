import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/products/comments.dart';
import 'package:kiloi_sm/repos/products/product_repo.dart';
import 'package:kiloi_sm/repos/products/products.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> productsList = [];
  List<Comment> commentsList = [];

  ProductRepo productRepo = ProductRepo.instance();
  late StreamSubscription<QuerySnapshot<Comment>> listener;

  late StreamController<List<Product>> _productController;
  late StreamSubscription<QuerySnapshot<Product>> productStreamSubscription;

  Stream<List<Product>> getProducts(String id, bool isAdmin) async* {
    kPrint("image is $isAdmin");
    try {
      _productController = StreamController<List<Product>>();
      Stream<QuerySnapshot<Product>> result = isAdmin
          ? productRepo.getAdminProducts(id: id)
          // mediaRepo.getMediaImages(id: id)
          : productRepo.getUserProducts();

      productStreamSubscription = result.listen((event) async {
        // imagesList.clear();
        List<Product> tempList = [];
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              if (change.doc.data() != null) {
                kPrint("my data is");
                bool hasAlreadyPresent = productsList.any(
                    (element) => element.image == change.doc.data()!.image);
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
          productsList.insert(0, element);
        });
        // imagesList.addAll(tempList.reversed);
        _productController.sink.add(productsList);
      });
      notifyListeners();
      yield* _productController.stream;
    } catch (error) {
      // setError(defaultErrorMessage);
      _productController.close(); // Close the controller in case of an error
      yield* Stream.error(error); // Return an error stream
    }
  }

  loadComments(String docId) {
    // commentsList.clear();
    List<Comment> tempMsgList = <Comment>[];
    final comments = productRepo.getMediaComments(docId: docId);

    listener = comments.listen((event) {
      // tempMsgList.clear();
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:

            // Handle If you add any new doc in firebase.
            if (change.doc.data() != null) {
              final msg = change.doc.data();
              if (msg != null
                  // &&
                  //     !commentsList.any((m) => m. == msg.docId)
                  ) {
                commentsList.add(msg!);
                kPrint("new comment ${commentsList.length} ${msg.docId}");
              }
            }

            break;
          case DocumentChangeType.modified:
            // TODO: Handle If you updated any doc in firebase.
            break;
          case DocumentChangeType.removed:
            // TODO: Handle If you deleted any doc in firebase.
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

  List<Product> onSearch(String query, List<Product> mediaList) {
    String trimmedQuery = query.trim().toLowerCase();

    // Return a list of MediaContent where the title contains the query
    return mediaList.where((element) {
      // Check if the title is not null and contains the query
      return element.title?.toLowerCase().contains(trimmedQuery) ?? false;
    }).toList();
  }

  @override
  void dispose() {
    productsList.clear();
    commentsList.clear();
    _productController.close();
    productStreamSubscription.cancel();

    // TODO: implement dispose
    super.dispose();
  }

  void callNotifier() {
    notifyListeners();
  }
}
