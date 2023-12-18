import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kiloi_sm/components/custom_app_button.dart';
import 'package:kiloi_sm/components/custom_auth_field.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/medias/media_repo.dart';
import 'package:kiloi_sm/repos/products/product_repo.dart';
import 'package:kiloi_sm/repos/products/products.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UploadMediaScreen extends StatelessWidget {
  static const String routeName = "/upload_media";
  File? imageFile;
  String mediaType;
  UploadMediaScreen({this.imageFile, required this.mediaType, super.key});

  late Size size;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => _ScreenNotifier(
            file: imageFile != null ? imageFile! : File(""),
            mediaType: mediaType),
        builder: (context, _) {
          var screenNotifier =
              Provider.of<_ScreenNotifier>(context, listen: false);
          size = MediaQuery.of(context).size;
          return Scaffold(
            // resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.08,
                          ),
                          mediaType == "image"
                              ? imageWidget()
                              : mediaType == "document"
                                  ? documentWidget(context)
                                  : (mediaType == "link" ||
                                          mediaType == "video")
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: size.height * 0.04,
                                          ),
                                          child: Form(
                                              key: screenNotifier.form,
                                              child: CustomTextField(
                                                  title: mediaType == "video"
                                                      ? "Enter Video Link"
                                                      : "Enter Link",
                                                  controller: screenNotifier
                                                      .videoLinkController,
                                                  isReadOnly: false,
                                                  suffixIcon: const SizedBox(),
                                                  onChange: (newVal) {},
                                                  focusNode: screenNotifier
                                                      .videoLinkNode,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  maxLines: 5,
                                                  nextFocusNode:
                                                      screenNotifier.titleNode,
                                                  onSaved: () {},
                                                  validator: screenNotifier
                                                      .emailValidator)),
                                        )
                                      : productWidgets(screenNotifier),
                          CustomTextField(
                              title: "Enter title",
                              controller: screenNotifier.titleController,
                              isReadOnly: false,
                              suffixIcon: const SizedBox(),
                              onChange: (newVal) {},
                              focusNode: screenNotifier.titleNode,
                              keyboardType: TextInputType.text,
                              maxLines: 5,
                              nextFocusNode: null,
                              onSaved: () {},
                              validator: (text) {
                                // if (text!.isEmpty) {
                                //   return "Please Enter Email Adress";
                                // }
                                return null;
                              }),
                        ],
                      ),
                      Consumer<AuthProvider>(
                          builder: (context, authNotifier, _) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 80),
                          child: CustomButton(
                              onTap: () {
                                if ((mediaType == "image" ||
                                        mediaType == "document") &&
                                    imageFile != null) {
                                  screenNotifier.uploadImageMediaContent(
                                      authNotifier, context);
                                } else if (mediaType == "video" ||
                                    mediaType == "link") {
                                  final isValid = screenNotifier
                                      .form.currentState!
                                      .validate();
                                  if (!isValid) {
                                    return;
                                  }
                                  screenNotifier.form.currentState!.save();
                                  screenNotifier.uploadVideoMediaContent(
                                      authNotifier, context);
                                } else if (mediaType == "product") {
                                  screenNotifier.uploadProduct(
                                      authNotifier, context);
                                }
                              },
                              title: "Upload"),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget productWidgets(_ScreenNotifier screenNotifier) {
    return Column(
      children: [
        imageWidget(),
        const SizedBox(
          height: 15,
        ),
        CustomTextField(
            title: "Category",
            controller: screenNotifier.categoryController,
            isReadOnly: false,
            suffixIcon: const SizedBox(),
            onChange: (newVal) {},
            focusNode: screenNotifier.categoryNode,
            keyboardType: TextInputType.text,
            maxLines: 5,
            nextFocusNode: screenNotifier.priceNode,
            onSaved: () {},
            validator: (text) {
              // if (text!.isEmpty) {
              //   return "Please Enter Email Adress";
              // }
              return null;
            }),
        const SizedBox(
          height: 15,
        ),
        CustomTextField(
            title: "Price",
            controller: screenNotifier.priceController,
            isReadOnly: false,
            suffixIcon: const SizedBox(),
            onChange: (newVal) {},
            focusNode: screenNotifier.priceNode,
            keyboardType: TextInputType.number,
            maxLines: 5,
            nextFocusNode: screenNotifier.titleNode,
            onSaved: () {},
            validator: (text) {
              // if (text!.isEmpty) {
              //   return "Please Enter Email Adress";
              // }
              return null;
            }),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget imageWidget() {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
              image: Image.file(imageFile!).image, fit: BoxFit.cover)),
    );
  }

  Widget documentWidget(context) {
    return Container(
      // height: 30,
      // padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.fieldBorderColor),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                  color: AppColors.appThemeColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              child: const Icon(
                Icons.edit_document,
                color: Colors.white,
              )),
          Expanded(
            child: Text(
              "${imageFile?.path}",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }
}

class _ScreenNotifier extends ChangeNotifier {
  File file;
  String mediaType;
  _ScreenNotifier({required this.file, required this.mediaType});
  TextEditingController titleController = TextEditingController();
  FocusNode titleNode = FocusNode();
  TextEditingController videoLinkController = TextEditingController();
  FocusNode videoLinkNode = FocusNode();
  TextEditingController categoryController = TextEditingController();
  FocusNode categoryNode = FocusNode();
  TextEditingController priceController = TextEditingController();
  FocusNode priceNode = FocusNode();
  MediaRepo mediaRepo = MediaRepo.instance();
  ProductRepo productRepo = ProductRepo.instance();
  final GlobalKey<FormState> form = GlobalKey<FormState>();

  uploadImageMediaContent(AuthProvider authNotifier, context) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false);
    try {
      String? mediaUrl =
          await mediaRepo.uploadImage(file, mediaType: mediaType);
      if (mediaUrl != null) {
        MediaContent mediaContent = MediaContent(
            id: authNotifier.userToken,
            image: mediaType == "image" ? mediaUrl : "",
            title: titleController.text,
            document: mediaType == "document" ? mediaUrl : "",
            addtime: Timestamp.now(),
            mediaType: mediaType);
        await mediaRepo
            .postMediaContent(mediaContent: mediaContent)
            .then((value) async {
          await mediaRepo.updateMediaContent(id: value.id);
        });
        EasyLoading.dismiss();
        kPrint("file data is $mediaUrl");
      }
      Navigator.of(context).pop();
    } catch (error) {
      EasyLoading.dismiss();
      Navigator.of(context).pop();
    }
  }

  uploadProduct(AuthProvider authNotifier, context) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false);
    try {
      final String uid = const Uuid().v4();
      String? mediaUrl =
          await mediaRepo.uploadImage(file, mediaType: mediaType);
      if (mediaUrl != null) {
        Product product = Product(
            addtime: Timestamp.now(),
            category: categoryController.text,
            id: authNotifier.userToken,
            image: mediaUrl,
            price: priceController.text,
            title: titleController.text);
        await productRepo.postProduct(product: product);
        EasyLoading.dismiss();
        kPrint("file data is $mediaUrl");
      }
      Navigator.of(context).pop();
    } catch (error) {
      kPrint("exception");
      EasyLoading.dismiss();
      Navigator.of(context).pop();
    }
  }

  uploadVideoMediaContent(AuthProvider authNotifier, context) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false);
    try {
      if (videoLinkController.text.isNotEmpty) {
        MediaContent mediaContent = MediaContent(
            id: authNotifier.userToken,
            image: "",
            title: titleController.text,
            document: "",
            video: mediaType == "video" ? videoLinkController.text : "",
            links: mediaType == "link" ? videoLinkController.text : "",
            addtime: Timestamp.now(),
            mediaType: mediaType);
        await mediaRepo
            .postMediaContent(mediaContent: mediaContent)
            .then((value) async {
          mediaRepo.updateMediaContent(id: value.id);
        });
        EasyLoading.dismiss();
      }
      Navigator.of(context).pop();
    } catch (error) {
      EasyLoading.dismiss();
      Navigator.of(context).pop();
    }
  }

  String? emailValidator(String? text) {
    if (text == null || text.isEmpty) {
      return "Please enter a URL";
    }
    final regex = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');
    if (!regex.hasMatch(text)) {
      return "Please enter a valid URL";
    }
    return null;
  }

  @override
  void dispose() {
    titleController.dispose();
    titleNode.dispose();
    videoLinkController.dispose();
    videoLinkNode.dispose();
    priceController.dispose;
    priceNode.dispose();
    categoryController.dispose();
    categoryNode.dispose();
    kPrint("dispose ....");

    super.dispose();
  }
}
