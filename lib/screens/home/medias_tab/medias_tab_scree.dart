import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_auth_field.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/chat_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/providers/products_provider.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/products/products.dart';
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

class _MediaTabScreenState extends State<MediaTabScreen>
    with SingleTickerProviderStateMixin {
  late _ScreenNotifier screenNotifier;
  TabController? tabController;
  final GlobalKey tabContentKey = GlobalKey();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tabController = DefaultTabController.of(
          tabContentKey.currentContext!); // (length: 2, vsync: this);

      tabController?.addListener(() {
        screenNotifier.searchController.text = "";
        // String text = screenNotifier.searchController.value.text;
        // _searchInCurrentTab(text);
      });
    });

    super.initState();
  }

  void _searchInCurrentTab(String text) {
    TabController tabController =
        DefaultTabController.of(tabContentKey.currentContext!);
    int index = tabController.index;
    kPrint(index.toString());
    screenNotifier.mediaTabsList[index].search(text);
  }

  @override
  void dispose() {
    screenNotifier.searchController.dispose();
    screenNotifier.searchNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _ScreenNotifier(
          context,
        ),
        builder: (context, _) {
          screenNotifier = Provider.of<_ScreenNotifier>(context, listen: false);
          var authProvider = Provider.of<AuthProvider>(context, listen: false);
          var mediaProvider =
              Provider.of<MediasProvider>(context, listen: false);
          var msgProvider = Provider.of<ChatProvider>(context, listen: false);
          return DefaultTabController(
            length: screenNotifier.mediaTabsList.length, //5,
            child: Scaffold(
                key: tabContentKey,
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
                            onChange: (text) => _searchInCurrentTab(text),
                            // onChange: screenNotifier
                            //     .mediaTabsList[tabController!.index]
                            //     .search, // screenNotifier.onSearch,
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
                        tabs: screenNotifier.mediaTabsList
                            .map((e) => Tab(
                                    icon: Text(
                                  e.tabText,
                                  //  style: Theme.of(context).textTheme.titleSmall,
                                )))
                            .toList()

                        /// Second tab
                        // Tab(
                        //     icon: Text(
                        //   "Documents",
                        //   // style: Theme.of(context).textTheme.titleSmall,
                        // )),
                        // Tab(
                        //     icon: Text(
                        //   "Links",
                        //   // style: Theme.of(context).textTheme.titleSmall,
                        // )),
                        // Tab(
                        //     icon: Text(
                        //   "Prodcuts",
                        //   // style: Theme.of(context).textTheme.titleSmall,
                        // )),
                        // ],
                        ),
                    Expanded(
                      child:
                          // Consumer<SearchFragmentData>(
                          //     builder: (context, searchFragment, _) {
                          //   return
                          Builder(builder: (context) {
                        return TabBarView(
                            // controller: tabController,
                            children: screenNotifier.mediaTabsList
                                .map((e) =>
                                    // e.tabText == "Products"
                                    //     ? ValueListenableBuilder<
                                    //             Map<String, dynamic>>(
                                    //         valueListenable: e.filteredMedia,
                                    //         // as ValueNotifier<List<Product>>,
                                    //         builder: (context, value, child) {
                                    //           if (screenNotifier
                                    //               .searchController.text.isEmpty) {
                                    //             e.clearList();
                                    //           }
                                    //           // Here, 'value' is the updated list of filteredMedia
                                    //           return (value["medialist"] != [] ||
                                    //                   value["query"] == "")
                                    //               ? e.searchWidget(
                                    //                   value["medialist"]
                                    //                       as List<Product>)
                                    //               : e.mainWidget(value["medialist"]
                                    //                   as List<Product>);
                                    //         })
                                    //     :
                                    ValueListenableBuilder<
                                        Map<String, dynamic>>(
                                      valueListenable: e.filteredMedia,
                                      builder: (context, value, child) {
                                        // If 'medialist' is null, use an empty list as default
                                        List<dynamic> mediaList =
                                            e.tabText == "Products"
                                                ? value["medialist"] ?? []
                                                : value["medialist"] ?? [];

                                        // Check the query
                                        String query = value["query"] ?? "";

                                        // Logic to decide which widget to show
                                        if (screenNotifier
                                            .searchController.text.isEmpty) {
                                          kPrint("clear");
                                          e.clearList();
                                          // After clearing, force update the mediaList and query from value
                                          mediaList = [];
                                          query = "";
                                        }

                                        // Use mediaList which is now guaranteed to be non-null
                                        return mediaList.isNotEmpty ||
                                                query.isNotEmpty
                                            ? e.searchWidget(mediaList)
                                            : e.mainWidget(mediaList);
                                      },
                                    ))
                                .toList()
                            // const [
                            //   VideoTab(),
                            //   ImageTab(),
                            //   DocumentsTab(),
                            //   LinksTab(),
                            //   ProductTab()
                            // ],
                            );
                      }),
                      // }),
                    ),
                  ],
                )),
          );
        });
  }
}

class _ScreenNotifier extends ChangeNotifier {
  late MediasProvider mediasProvider;
  late ProductsProvider productsProvider;
  _ScreenNotifier(
    BuildContext context,
  ) {
    // tabController = controller;
    mediasProvider = Provider.of<MediasProvider>(context, listen: false);
    productsProvider = Provider.of<ProductsProvider>(context, listen: false);
  }
  TextEditingController searchController = TextEditingController();
  late TabController tabController;
  FocusNode searchNode = FocusNode();

  late final mediaTabsList = [
    SearchFragmentData<MediaContent>(
        searchWidget: (list) => CustomSearchedTab(
              filteredList: list,
              icon: Icons.play_arrow,
            ),
        searchFunction: (query) {
          return mediasProvider.onSearch(query!, mediasProvider.videosList);
        },
        tabText: "Video",
        searchQuery: searchController.text,
        mainWidget: (list) => const VideoTab()),
    SearchFragmentData<MediaContent>(
        searchWidget: (list) => CustomSearchedTab(
              filteredList: list,
              icon: Icons.image,
            ),
        searchFunction: (query) {
          return mediasProvider.onSearch(query!, mediasProvider.imagesList);
        },
        tabText: "Images",
        searchQuery: searchController.text,
        mainWidget: (list) => const ImageTab()),
    SearchFragmentData<MediaContent>(
        searchWidget: (list) => CustomSearchedTab(
              filteredList: list,
              icon: Icons.image,
            ),
        searchFunction: (query) {
          return mediasProvider.onSearch(query!, mediasProvider.documentsList);
        },
        tabText: "Documents",
        searchQuery: searchController.text,
        mainWidget: (list) => const DocumentsTab()),
    SearchFragmentData<MediaContent>(
        searchWidget: (list) => CustomSearchedTab(
              filteredList: list,
              icon: Icons.link,
            ),
        searchFunction: (query) {
          return mediasProvider.onSearch(query!, mediasProvider.linksList);
        },
        tabText: "Links",
        searchQuery: searchController.text,
        mainWidget: (list) => const LinksTab()),
    SearchFragmentData<Product>(
        searchWidget: (list) => CustomProductSearchedTab(filteredList: list),
        // CustomSearchedTab(
        //       filteredList: list,
        //       icon: Icons.link,
        //     ),
        searchFunction: (query) {
          return productsProvider.onSearch(
              query!, productsProvider.productsList);
        },
        tabText: "Products",
        searchQuery: searchController.text,
        mainWidget: (list) => const ProductTab())
  ];
  @override
  void dispose() {
    searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}

class SearchFragmentData<DATA> {
  final Widget Function(dynamic list) searchWidget;
  final Widget Function(dynamic list) mainWidget;
  ValueNotifier<Map<String, dynamic>> filteredMedia =
      ValueNotifier({"medialist": <DATA>[], "query": ""});
  final List<DATA> Function(String? text) searchFunction;
  final String tabText;
  String searchQuery;

  SearchFragmentData({
    required this.searchWidget,
    required this.searchFunction,
    required this.tabText,
    required this.mainWidget,
    required this.searchQuery,
  });

  void search(String query) {
    // Perform the search
    var newMediaList = searchFunction(query);

    // Create a new map and assign it to 'filteredMedia.value'
    filteredMedia.value = {"medialist": newMediaList, "query": query};

    kPrint("${filteredMedia.value}");
  }

  void clearList() {
    filteredMedia.value = {"medialist": [], "query": ""};
    kPrint("${filteredMedia.value}");
  }
}
