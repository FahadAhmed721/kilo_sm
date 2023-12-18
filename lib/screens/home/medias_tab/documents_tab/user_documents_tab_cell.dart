import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserDocumentsTabCell extends StatelessWidget {
  ScrollController scrollController;
  List<MediaContent> documentsList;
  final Function(String url) onDocumentTap;

  UserDocumentsTabCell(
      {required this.onDocumentTap,
      required this.documentsList,
      required this.scrollController,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 37),
        itemCount: documentsList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          crossAxisSpacing: 10, // Horizontal space between items
          mainAxisSpacing: 10, // Vertical space between items
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onDocumentTap(documentsList[index].document!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.uploadButtonColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Icon(
                      Icons.edit_document,
                      color: Colors.white,
                    ),
                  ),
                )),
                Text(
                  documentsList[index].title ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          );
        });
  }

  void launchURL(url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {}
  }
}
