import 'package:flutter/material.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/chat_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/providers/products_provider.dart';
import 'package:kiloi_sm/screens/home/medias_tab/medias_tab_scree.dart';
import 'package:kiloi_sm/screens/home/profile/chat_screen.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String route_name = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [const MediaTabScreen(), const ChatScreen()];

  @override
  Widget build(BuildContext context) {
    var chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      resizeToAvoidBottomInset: isKeyboardOpen ? true : false,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 20.0,
        surfaceTintColor: AppColors.bottomNevigationBarColor,
        // height: 60,
        // shadowColor: AppColors.bottomNevigationBarColor,
        color: AppColors.bottomNevigationBarColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0
                      ? AppColors.appThemeColor
                      : Colors.white),
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            IconButton(
              icon: Icon(Icons.person,
                  color: _selectedIndex == 1
                      ? AppColors.appThemeColor
                      : Colors.white),
              onPressed: () {
                _onItemTapped(1);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isKeyboardOpen
          ? Container(
              height: 0,
            )
          : FloatingActionButton(
              backgroundColor: AppColors.appThemeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(
                Icons.add,
                size: 40,
              ),
              onPressed: () {
                // _onItemTapped(2);
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Consumer<AuthProvider>(builder: (context, authNotifier, _) {
      //   return Center(
      //     child: Column(
      //       children: [
      //         Text(
      //           authNotifier.getUserContent.name!,
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         Text(
      //           authNotifier.getUserContent.token!,
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         Text(
      //           authNotifier.getUserContent.email!,
      //           style: TextStyle(color: Colors.white),
      //         ),
      //       ],
      //     ),
      //   );
      // }),
    );
  }
}
