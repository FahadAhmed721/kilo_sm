import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/chat_provider.dart';
import 'package:kiloi_sm/screens/home/profile/chat/chat_list.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatProvider chatProvider;
  late AuthProvider authProvider;
  ScrollController messageScrollController = ScrollController();
  final ImagePicker imagePicker = ImagePicker();
  File? _photo;

  @override
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    chatProvider.loadMessages();

    /// This addlistener is for pagination
    messageScrollController.addListener(() {
      if (messageScrollController.offset >=
          messageScrollController.position.maxScrollExtent) {
        // if (isLoadMore) {
        //   state.isLoading.value = true;
        //   // to stop unecessary request to firebase
        //   isLoadMore = false;
        chatProvider.asyncLoadMoreData();
        // }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    messageScrollController.dispose();
    super.dispose();
  }

  Future onPickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      await chatProvider.sendImage();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      // appBar: _buildAppBar(),
      body: SafeArea(
          child: Stack(
        children: [
          ChatList(messageController: messageScrollController),
          Positioned(
            bottom: isKeyboardOpen ? 0 : 30,
            left: 20,
            right: 20,
            // top: 0,
            child: Row(
              children: [
                Expanded(
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
                            controller: chatProvider.chatMessageController,
                            keyboardType: TextInputType.multiline,
                            autofocus: false,
                            focusNode: chatProvider.messageFocusNode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14),

                            // onTapOutside: (event) {

                            //   FocusManager
                            //     .instance.primaryFocus
                            //     ?.unfocus();},
                            decoration: const InputDecoration(
                                hintText: "Type your message here",
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    left: 15, top: 0, bottom: 0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent))),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            chatProvider.sendMessage(authProvider.userToken,
                                authProvider.getUserContent.name!);
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                const CircleAvatar(
                  backgroundColor: AppColors.appThemeColor,
                  radius: 20,
                  child: Center(
                    child: Icon(Icons.add),
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
