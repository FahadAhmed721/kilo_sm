import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_auth_field.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/chat_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/screens/home/medias_tab/documents_tab/documents_tab.dart';
import 'package:kiloi_sm/screens/home/medias_tab/images_tab/images_tab.dart';
import 'package:kiloi_sm/screens/home/medias_tab/links_tab/links_tab.dart';
import 'package:kiloi_sm/screens/home/medias_tab/products_tab/products_tab.dart';
import 'package:kiloi_sm/screens/home/medias_tab/videos_tab/videos_tab.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class MediaTabScreen extends StatefulWidget {
  const MediaTabScreen({super.key});

  @override
  State<MediaTabScreen> createState() => _MediaTabScreenState();
}

class _MediaTabScreenState extends State<MediaTabScreen> {
  late _ScreenNotifier screenNotifier;

  @override
  void dispose() {
    screenNotifier.searchController.dispose();
    screenNotifier.searchNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _ScreenNotifier(),
        builder: (context, _) {
          screenNotifier = Provider.of<_ScreenNotifier>(context, listen: false);
          var authProvider = Provider.of<AuthProvider>(context, listen: false);
          var mediaProvider =
              Provider.of<MediasProvider>(context, listen: false);
          var msgProvider = Provider.of<ChatProvider>(context, listen: false);
          return DefaultTabController(
            length: 5,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                    // backgroundColor: Colors.amber,
                    toolbarHeight: kTextTabBarHeight - 15,
                    actions: [
                      IconButton(
                          onPressed: () async {
                            await authProvider.logOut();
                            mediaProvider.clearLists();
                            msgProvider.clearMessages();
                          },
                          icon: const Icon(
                            Icons.logout_outlined,
                            color: Colors.white,
                          ))
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size(double.infinity, 80),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                        child: CustomTextField(
                            title: "Search for pictures, videos, docs...",
                            controller: screenNotifier.searchController,
                            isReadOnly: false,
                            suffixIcon: const SizedBox(),
                            onChange: (newVal) {},
                            focusNode: screenNotifier.searchNode,
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                            nextFocusNode: null,
                            onSaved: () {},
                            validator: (text) {
                              // if (text!.isEmpty) {
                              //   return "Please Enter Password";
                              // }
                              // return null;
                            }),
                      ),
                    )),
                body: Column(
                  children: [
                    TabBar(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 20),
                      tabAlignment: TabAlignment.center,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      unselectedLabelColor: AppColors.fieldBorderColor,
                      indicatorColor: AppColors.appThemeColor,
                      // labelColor: Colors.white,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 14),

                      // unselectedLabelColor: AppColors.fieldBorderColor,
                      // unselectedLabelStyle:
                      //     const TextStyle(color: AppColors.fieldBorderColor),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(
                            icon: Text(
                          "Videos",
                          //  style: Theme.of(context).textTheme.titleSmall,
                        )), // First tab
                        Tab(
                            icon: Text(
                          "Images",
                          // style: Theme.of(context).textTheme.titleSmall,
                        )),

                        /// Second tab
                        Tab(
                            icon: Text(
                          "Documents",
                          // style: Theme.of(context).textTheme.titleSmall,
                        )),
                        Tab(
                            icon: Text(
                          "Links",
                          // style: Theme.of(context).textTheme.titleSmall,
                        )),
                        Tab(
                            icon: Text(
                          "Prodcuts",
                          // style: Theme.of(context).textTheme.titleSmall,
                        )),
                      ],
                    ),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          VideoTab(),
                          ImageTab(),
                          DocumentsTab(),
                          LinksTab(),
                          ProductTab()
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
}
