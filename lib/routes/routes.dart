import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_web_view.dart';
import 'package:kiloi_sm/components/web_view.dart';
import 'package:kiloi_sm/screens/auth/sign_in.dart';
import 'package:kiloi_sm/screens/auth/signup_screen.dart';
import 'package:kiloi_sm/screens/auth/splash_screen.dart';
import 'package:kiloi_sm/screens/home/home.dart';
import 'package:kiloi_sm/screens/home/medias_tab/comments_screen.dart';
import 'package:kiloi_sm/screens/home/medias_tab/upload_media_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case SignInScreen.routeName:
        // final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
        );
      case SignUpScreen.route_name:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SignUpScreen(isAdmin: args?["isAdmin"]),
        );
      case HomeScreen.route_name:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case CommentsScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CommentsScreen(
            mediaContent: args?['mediaContent'],
          ),
        );
      case WebView.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WebView(
            url: args?['url'],
            appBarTitle: args?['appbarTitle'],
          ),
        );
      case UploadMediaScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => UploadMediaScreen(
            mediaType: args!["mediaType"],
            imageFile: args["imageFile"],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => UndefinedView(name: settings.name),
        );
    }
  }
}

class UndefinedView extends StatelessWidget {
  final String? name;

  const UndefinedView({Key? key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Not Found'),
      ),
      body: Center(
        child: Text('No route defined for $name'),
      ),
    );
  }
}
