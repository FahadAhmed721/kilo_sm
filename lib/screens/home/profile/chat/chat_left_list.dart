import 'package:flutter/material.dart';
import 'package:kiloi_sm/repos/messages/msg_content.dart';
import 'package:kiloi_sm/utils/app_colors.dart';

class ChatLeftList extends StatelessWidget {
  Msgcontent msgcontent;
  ChatLeftList({required this.msgcontent, super.key});
  String? imagPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (msgcontent.name != null)
              msgcontent.name != null
                  ? Text(
                      "${msgcontent.name}",
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Container(),
              ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 250, minHeight: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.fieldBorderColor),
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
        ],
      ),
    );
  }
}
