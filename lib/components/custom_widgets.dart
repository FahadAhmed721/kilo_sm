import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/products/products.dart';
import 'package:kiloi_sm/screens/home/medias_tab/products_tab/products_tab.dart';
import 'package:kiloi_sm/utils/app_assets.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class AuthScreensHeader extends StatelessWidget {
  const AuthScreensHeader({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.height * 0.05,
      ),
      child: Column(
        children: [
          Image.asset(
            MyAssets.appLogo,
            scale: 4,
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Text(
              "Welcome to KilioSm",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Text(
            "Easy access to all your files!",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class ORWidget extends StatelessWidget {
  const ORWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 2,
            // width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.fieldBorderColor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("OR", style: TextStyle(color: AppColors.fieldHintColor)),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
                color: AppColors.fieldBorderColor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class UploadButton extends StatelessWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          color: AppColors.uploadButtonColor,
          borderRadius: BorderRadius.circular(10)),
      child: const Center(
        child: Icon(
          Icons.file_upload_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CustomImage extends StatelessWidget {
  String title;
  String url;
  GestureTapCallback onTap;
  CustomImage(
      {required this.title, required this.url, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: url, // Replace with your image URL
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
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
              errorWidget: (context, url, error) => const Icon(
                  Icons.error), // Widget to display when there's an error
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
          Text(
            title,
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
  }
}

class ProductsWidget extends StatelessWidget {
  String url;
  String title;
  String price;
  String category;
  GestureTapCallback onTap;
  final bool shouldShowPC;
  ProductsWidget(
      {required this.category,
      required this.price,
      required this.title,
      required this.url,
      required this.onTap,
      this.shouldShowPC = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldShowPC)
          Text(
            category,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleLarge!,
            // .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (shouldShowPC)
          const SizedBox(
            height: 5,
          ),
        GestureDetector(
          onTap: () => onTap(),
          child: SizedBox(
            height: 150,
            child: CachedNetworkImage(
              imageUrl: url, // Replace with your image URL
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
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
              errorWidget: (context, url, error) => const Icon(
                  Icons.error), // Widget to display when there's an error
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                // maxLines: 1,
                // overflow: TextOverflow.ellipsis,
              ),
            ),
            if (shouldShowPC)
              Text(
                "\$ $price",
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.titleMedium!,
                // .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class CustomSearchedTab extends StatelessWidget {
  List<MediaContent> filteredList;
  IconData icon;

  CustomSearchedTab({
    super.key,
    required this.filteredList,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return filteredList.isEmpty
        ? Center(
            child: Text(
              "No Data",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          )
        : ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              MediaContent media = filteredList[index];
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: AppColors.uploadButtonColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      media.title ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  ],
                ),
              );
            });
  }
}

class CustomProductSearchedTab extends StatelessWidget {
  List<Product> filteredList;

  CustomProductSearchedTab({
    super.key,
    required this.filteredList,
  });

  @override
  Widget build(BuildContext context) {
    return filteredList.isEmpty
        ? Center(
            child: Text(
              "No Data",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          )
        : ChangeNotifierProvider(
            create: (context) => ProductScreenNotifier(context),
            builder: (context, _) {
              var screenNotifierProvider =
                  Provider.of<ProductScreenNotifier>(context, listen: false);
              return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 38, horizontal: 37),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    Product product = filteredList[index];
                    return ProductsWidget(
                      category: product.category!,
                      onTap: () {
                        screenNotifierProvider.makePayment(
                            product.price ?? "", context);
                      },
                      price: product.price!,
                      title: product.title!,
                      url: product.image!,
                    );
                  });
            });
  }
}
