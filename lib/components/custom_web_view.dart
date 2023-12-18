// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class CustomWebViewScreen extends StatefulWidget {
  CustomWebViewScreen(
      {Key? key,
      this.onNavigationRequest,
      this.onPageFinished,
      this.onPageStarted,
      this.onProgress,
      this.onWebResourceError,
      required this.url,
      this.appBar = true,
      this.appBarTitle = ''})
      : super(key: key);

  String? url;
  String? appBarTitle;
  final bool appBar;
  void Function(WebResourceError)? onWebResourceError;
  FutureOr<NavigationDecision> Function(NavigationRequest)? onNavigationRequest;
  void Function(int)? onProgress;
  void Function(String)? onPageStarted;
  void Function(String)? onPageFinished;

  @override
  State<CustomWebViewScreen> createState() => _CustomWebViewScreenState();
}

class _CustomWebViewScreenState extends State<CustomWebViewScreen> {
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();
  late final WebViewController _controller;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
            widget.onProgress ?? () {};
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            widget.onPageStarted ?? () {};
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            widget.onPageFinished ?? () {};
          },
          onWebResourceError: (WebResourceError error) {
            widget.onWebResourceError ?? () {};

            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (widget.onNavigationRequest != null) {
              widget.onNavigationRequest!(request);
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(
          // widget.appBar
          //   ? Uri.parse('${widget.url!}?data=mobile')
          //   // .replace(queryParameters: {'device': 'mobile'})
          //   :
          Uri.parse(widget.url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //WebViewController? webViewController;
    return Scaffold(
      appBar: widget.appBar
          ? AppBar(
              centerTitle: true,
              title: Text(widget.appBarTitle ?? ''),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: _progressBar(progress, context),
              ),
            )
          : AppBar(
              centerTitle: true,
              title: Text(widget.appBarTitle ?? ''),
            ),
      body: WebViewWidget(
        controller: _controller,
      ),
      //floatingActionButton: favoriteButton(),
    );
  }

  Widget _progressBar(double progress, BuildContext contenxt) {
    return LinearProgressIndicator(
      backgroundColor: Colors.white70.withOpacity(0),
      value: progress == 1.0 ? 0 : progress,
      valueColor:
          AlwaysStoppedAnimation(const Color(0xFFFF7200).withOpacity(0.5)),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture, {Key? key})
      : super(key: key);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No back history item')),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No forward history item')),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
