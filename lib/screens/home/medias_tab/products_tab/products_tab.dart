import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/products_provider.dart';
import 'package:kiloi_sm/repos/products/product_repo.dart';
import 'package:kiloi_sm/repos/products/products.dart';
import 'package:kiloi_sm/screens/home/medias_tab/upload_media_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  late ProductsProvider productsProvider;
  late AuthProvider authProvider;
  late Stream<List<Product>> stream;

  @override
  void initState() {
    productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    kPrint("User Data is ${authProvider.getUserContent.isAdmin}");
    productsProvider.productsList.clear();

    stream = fetchProducts();

    super.initState();
  }

  Stream<List<Product>> fetchProducts() async* {
    yield* productsProvider.getProducts(
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
                return Consumer2<ProductsProvider, AuthProvider>(
                    builder: (context, productNotifier, authNotifier, _) {
                  // kPrint("isAdmin ${authNotifier.getUserContent.isAdmin}");
                  return ListView.builder(
                      controller:
                          screenNotifierProvider.messageScrollController,
                      padding: const EdgeInsets.symmetric(
                          vertical: 38, horizontal: 37),
                      itemCount: !authNotifier.getUserContent.isAdmin!
                          ? productNotifier.productsList.length
                          : 1 + productNotifier.productsList.length,
                      itemBuilder: (context, index) {
                        Product? product =
                            screenNotifierProvider.getIndexedProduct(
                                authNotifier.getUserContent.isAdmin!,
                                index,
                                productNotifier.productsList);

                        return !authNotifier.getUserContent.isAdmin!
                            ? Container(
                                margin: const EdgeInsets.only(top: 25),
                                child: ProductsWidget(
                                    category: product!.category ?? "",
                                    price: product.price ?? "",
                                    url: product.image ?? "",
                                    title: product.title ?? ""),
                              )
                            : product == null
                                ? InkWell(
                                    onTap: () async {
                                      await screenNotifierProvider
                                          .pickImage(context);
                                    },
                                    child: const UploadButton())
                                : Container(
                                    margin: const EdgeInsets.only(top: 25),
                                    child: ProductsWidget(
                                        category: product.category ?? "",
                                        price: product.price ?? "",
                                        url: product.image ?? "",
                                        title: product.title ?? ""),
                                  );
                      });
                });
              });
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  final picker = ImagePicker();
  ProductRepo productRepo = ProductRepo.instance();
  final uniqueId = const Uuid().v4();
  bool loadMore = false;
  late ProductsProvider productsProvider;
  late AuthProvider authProvider;
  ScrollController messageScrollController = ScrollController();
  _ScreenNotifier(context) {
    productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    messageScrollController.addListener(() {
      if (messageScrollController.offset + 20 >=
          messageScrollController.position.maxScrollExtent) {
        kPrint("hello");
        asyncLoadMoreData(authProvider.userToken,
            productsProvider.productsList.last.addtime!);
      }
    });
    // });
  }

  Future<void> pickImage(context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.pushNamed(context, UploadMediaScreen.routeName, arguments: {
        "mediaType": "product",
        "imageFile": File(pickedFile.path)
      });
    } else {
      // Handle no image selected.
    }
  }

  Product? getIndexedProduct(
      bool isAdmin, int index, List<Product> productList) {
    // If the index is out of range for the productList, return null.
    if (index < 0) {
      return null;
    }

    // If the user is an admin and index is 0, return null.
    // This assumes index 0 should be ignored for admins.
    if (isAdmin && index == 0) {
      return null;
    }

    // For an admin, adjust the index to skip the first product.
    final adjustedIndex = isAdmin ? index - 1 : index;
    return productList[adjustedIndex];
  }

  @override
  void dispose() {
    messageScrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> asyncLoadMoreData(
    String id,
    Timestamp lastTime,
  ) async {
    loadMore = true;
    QuerySnapshot<Product> imagesList = authProvider.getUserContent.isAdmin!
        ? await productRepo.loadMoreAdminProducts(id: id, lastTime: lastTime)
        : await productRepo.loadMoreUserProducts(lastTime: lastTime);
    kPrint("new products ${imagesList.docs.length}");
    if (imagesList.docs.isNotEmpty) {
      imagesList.docs.forEach((element) {
        bool hasAlreadyPresent = productsProvider.productsList
            .any((media) => media.image == element.data().image);
        if (!hasAlreadyPresent) {
          productsProvider.productsList.add(element.data());
        }
      });
      productsProvider.callNotifier();
    }
    loadMore = false;
    // notifyListeners();
  }
}
