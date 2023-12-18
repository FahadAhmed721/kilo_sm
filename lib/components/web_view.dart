import 'package:flutter/material.dart';
import 'package:kiloi_sm/components/custom_web_view.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

// class WebView extends StatelessWidget {
//   static const String routeName = "/web_view";
//   String url;
//   String? appBarTitle;
//   WebView({required this.url, this.appBarTitle, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomWebViewScreen(
//       url: url,
//       appBarTitle: appBarTitle ?? "",
//       onProgress: (pro) {
//         // _pro = pro;
//         // setState(() {});
//       },
//       onPageFinished: (v) async {
//         // await Future.delayed(const Duration(milliseconds: 300), () {
//         //   // _hiPro = true;
//         //   // setState(() {});
//         // });
//       },
//       onWebResourceError: (e) async {
//         // await Future.delayed(const Duration(milliseconds: 300), () {
//         //   // errorMsg = e.description;
//         //   // _hiPro = true;
//         //   // setState(() {});
//         // });
//       },
//       onNavigationRequest: (NavigationRequest request) {
//         if (request.url.contains("mailto:")) {
//           kPrint("mailto");
//           return NavigationDecision.prevent;
//         } else if (request.url.contains("tel:")) {
//           kPrint("tel");
//           _launchURL(request.url);
//           return NavigationDecision.prevent;
//         }
//         return NavigationDecision.navigate;
//       },
//     );
//   }

//   _launchURL(url) async {
//     if (await canLaunchUrlString(url)) {
//       await launchUrlString(url);
//     } else {}
//   }
// }
class WebView extends StatefulWidget {
  WebView({super.key, required this.url, this.appBarTitle});

  static const String routeName = "/web_view";
  String url;
  String? appBarTitle;

  // static pushWebPage({String? title, String? url}) {
  //   push(RoutePath.webPage, extra: {"title": title, "url": url});
  // }

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebView> {
  int _pro = 0;
  bool _hiPro = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _dataView();
  }

  Widget _dataView() {
    if (errorMsg != null) {
      return Center(
        child: Text(errorMsg!),
      );
    }
    return CustomWebViewScreen(
      url: widget.url,
      appBar: false,
      appBarTitle: widget.appBarTitle,
      onProgress: (pro) {
        // setState(() {
        //   _pro = pro;
        // });
      },
      onPageFinished: (v) {
        kPrint("data data");
        // await Future.delayed(const Duration(milliseconds: 300), () {

        // setState(() {
        //   _hiPro = true;
        // });
        // });
      },
      onWebResourceError: (e) async {
        await Future.delayed(const Duration(milliseconds: 300), () {
          errorMsg = e.description;
          _hiPro = true;
          setState(() {});
        });
      },
      onNavigationRequest: (NavigationRequest request) {
        // if (request.url.contains("mailto:")) {
        //   return NavigationDecision.prevent;
        // } else if (request.url.contains("tel:")) {
        //   _launchURL(request.url);
        //   return NavigationDecision.prevent;
        // }
        return NavigationDecision.navigate;
      },
    );
  }

  _launchURL(url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {}
  }
}
