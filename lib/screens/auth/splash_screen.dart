import 'package:flutter/material.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/screens/auth/sign_in.dart';
import 'package:kiloi_sm/screens/home/home.dart';
import 'package:kiloi_sm/utils/app_assets.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   provider.getLocalData();

    //   if (provider.userToken.isNotEmpty) {
    //     Navigator.pushNamed(context, HomeScreen.route_name);
    //   } else {
    //     kPrint("data");
    //     Navigator.pushNamed(context, SignInScreen.routeName);
    //   }
    // });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //   await auth.getLocalData().then((value) {
      //     if (auth.userToken.isNotEmpty) {
      //       Navigator.pushNamed(context, HomeScreen.route_name);
      //     } else {
      //       kPrint("data");
      //       Navigator.pushNamed(context, SignInScreen.routeName);
      //     }
      //   });
      // });

      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                MyAssets.appLogo,
                scale: 4,
              ),
              const SizedBox(height: 22),
              Text(
                "Easy access to all your files!",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              InkWell(
                onTap: () {
                  var provider =
                      Provider.of<AuthProvider>(context, listen: false);
                  // provider.getLocalData();
                  Navigator.pushNamed(context, SignInScreen.routeName);
                  // Navigator.pushReplacementNamed(context, SignInScreen.routeName);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 87, bottom: 210),
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                      color: AppColors.appThemeColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.arrow_forward),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
