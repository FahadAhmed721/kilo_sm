import 'package:flutter/material.dart';
import 'package:kiloi_sm/repos/messages/msg_content.dart';
import 'package:kiloi_sm/utils/app_colors.dart';

class ChatRightList extends StatelessWidget {
  Msgcontent msgcontent;
  ChatRightList({required this.msgcontent, super.key});
  String? imagPath;
  // replaceImagePathToCirrectPath() {
  //   if (msgcontent.type == MessageSecondryType.IMAGE.name) {
  //     imagPath =
  //         msgcontent.content?.replaceAll("http://localhost/", SERVER_API_URL);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250, minHeight: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.appThemeColor),
                      child: Text(
                        msgcontent.content ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      )),
                ],
              )),
        ],
      ),
    );
  }
}
