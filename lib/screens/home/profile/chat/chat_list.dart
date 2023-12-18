import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/chat_provider.dart';
import 'package:kiloi_sm/screens/home/profile/chat/chat_left_list.dart';
import 'package:kiloi_sm/screens/home/profile/chat/chat_right_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatelessWidget {
  ScrollController messageController;
  ChatList({required this.messageController, super.key});

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.only(bottom: 90),
      child: GestureDetector(
        onTap: () {
          // controller.closeAllPop();
        },
        child: Consumer<ChatProvider>(builder: (context, chatNotifier, _) {
          return CustomScrollView(
            controller: messageController,
            reverse: true,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  var item = chatNotifier.messagesList[index];
                  if (auth.userToken == item.token) {
                    return ChatRightList(msgcontent: item);
                  } else {
                    return ChatLeftList(
                      msgcontent: item,
                    );
                  }
                }, childCount: chatNotifier.messagesList.length)),
              ),

              // SliverPadding(
              //     padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 0.w),
              //     sliver: SliverToBoxAdapter(
              //       child: controller.state.isLoading.value
              //           ? const Align(
              //               alignment: Alignment.center,
              //               child: SizedBox(
              //                 height: 10,
              //                 width: 10,
              //                 child: CircularProgressIndicator(),
              //               ),
              //             )
              //           : Container(),
              //     )),
            ],
          );
        }),
      ),
    );
  }
}
