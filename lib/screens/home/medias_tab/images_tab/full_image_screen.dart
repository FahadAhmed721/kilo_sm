import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullImageView extends StatelessWidget {
  static const String routeName = "/full_image_view";
  String url;
  FullImageView({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedNetworkImage(
        imageUrl: url, // Replace with your image URL
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.contain,
                )),
          );
        },
        placeholder: (context, url) => const Center(
          child: Icon(
            Icons.image,
            color: Colors.white,
          ),
          //  SizedBox(
          //     height: 10, width: 10, child: CircularProgressIndicator()),
        ), // Placeholder widget while loading
        errorWidget: (context, url, error) =>
            const Icon(Icons.error), // Widget to display when there's an error
        fit: BoxFit.cover, // Adjust the fit as needed
      ),
    );
  }
}
