import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kiloi_sm/global.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/providers/chat_provider.dart';
import 'package:kiloi_sm/providers/media_provider.dart';
import 'package:kiloi_sm/providers/products_provider.dart';
//import 'package:kiloi_sm/repos/user/user.dart';
import 'package:kiloi_sm/routes/routes.dart';
import 'package:kiloi_sm/screens/auth/sign_in.dart';
//import 'package:kiloi_sm/screens/auth/splash_screen.dart';
import 'package:kiloi_sm/screens/home/home.dart';
import 'package:kiloi_sm/theme/theme.dart';
import 'package:kiloi_sm/utils/firebase_messaging_handler.dart';
//import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

kPrint(String data) {
  if (kDebugMode) {
    print(data);
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await Global.iniit();
  Stripe.publishableKey =
      "pk_live_51OJ0YCLawvH1yXDfipHsni0lOUR5Kld0dTIwP8SmTKlNi0gS299fj1gpxFwwUtKjGlBHiLiNB3maI6x41yzsOcG400ctfGqPA4";
  await dotenv.load(fileName: "assets/.env");
  firebaseChatInit().then((value) {
    FirebaseMessagingHandler.config();
  });
  runApp(const MyApp());
}

/// Handle Notifications
Future firebaseChatInit() async {
  FirebaseMessaging.onBackgroundMessage(
      FirebaseMessagingHandler.firebaseMessagingBackground);
  if (Platform.isAndroid) {
    await FirebaseMessagingHandler.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(FirebaseMessagingHandler.channel_message);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductsProvider(),
        ),
        ChangeNotifierProvider(create: (context) => MediasProvider())
      ],
      child: Consumer<AuthProvider>(builder: (context, auth, _) {
        return MaterialApp(
          key: navigatorKey,
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.appTheme,
          home:
              // const SplashScreen(),
              auth.userToken.isNotEmpty
                  ? const HomeScreen()
                  : FutureBuilder<bool>(
                      future: auth.getLocalData(),
                      builder: (context, snapShot) {
                        return snapShot.connectionState ==
                                ConnectionState.waiting
                            ? const SignInScreen()
                            : auth.userToken.isEmpty
                                ? const SignInScreen()
                                : const HomeScreen();
                      }),
          onGenerateRoute: RouteGenerator.generateRoute,
          builder: EasyLoading.init(),
        );
      }),
    );
  }
}

class NewHome extends StatelessWidget {
  const NewHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber,
        child: Center(
          child: GestureDetector(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logOut();
              },
              child: Text("logout")),
        ),
      ),
    );
  }
}
