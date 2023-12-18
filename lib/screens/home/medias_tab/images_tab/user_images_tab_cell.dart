import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/screens/home/medias_tab/comments_screen.dart';

class UserImageTabCell extends StatelessWidget {
  ScrollController scrollController;
  List<MediaContent> imagesList;

  UserImageTabCell(
      {required this.imagesList, required this.scrollController, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 37),
        itemCount: imagesList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          crossAxisSpacing: 10, // Horizontal space between items
          mainAxisSpacing: 10, // Vertical space between items
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: CustomImage(
                onTap: () => Navigator.pushNamed(
                        context, CommentsScreen.routeName,
                        arguments: {
                          "mediaContent": imagesList[index],
                        }),
                title: imagesList[index].title!,
                url: imagesList[index].image!),
          );
        });
  }
}
