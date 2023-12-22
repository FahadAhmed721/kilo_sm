import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// String client_secret =
//     "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";

//import 'package:stripe_sdk/stripe_sdk.dart';
class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  late ProductsProvider productsProvider;
  late AuthProvider authProvider;
  late Stream<List<Product>> stream;
  Map<String, dynamic>? paymentIntent;
  String toPayPrice = "";
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

  Future<void> makePayment(amountToPay) async {
    kPrint("make payment called");
    try {
      //STEP 1: Create Payment Intent
      kPrint("Creating PaymentIntent");
      paymentIntent = await createPaymentIntent(amountToPay, 'USD');

      //STEP 2: Initialize Payment Sheet
      kPrint("initializing Intent");
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.light,
                  merchantDisplayName: 'Ikay'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  displayPaymentSheet() async {
    kPrint("displaying patment sheet");
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      kPrint('Error is:---> $e');
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      kPrint('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
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
                        toPayPrice = product?.price ?? " ";
                        return !authNotifier.getUserContent.isAdmin!
                            ? Container(
                                margin: const EdgeInsets.only(top: 25),
                                child: ProductsWidget(
                                    category: product!.category ?? "",
                                    price: product.price ?? "",
                                    url: product.image ?? "",
                                    onTap: () {
                                      kPrint("pressed");
                                      kPrint(product.price ?? "");
                                      makePayment(product.price ?? "");
                                    },
                                    title: product.title ?? ""),
                              )
                            : product == null
                                ? InkWell(
                                    onTap: () async {
                                      kPrint("pressed1");
                                      // makePayment(product?.price ?? "");
                                      await screenNotifierProvider
                                          .pickImage(context);
                                    },
                                    child: const UploadButton())
                                : Container(
                                    margin: const EdgeInsets.only(top: 25),
                                    child: ProductsWidget(
                                        onTap: () {},
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
