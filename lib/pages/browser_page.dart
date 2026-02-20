import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:lambo01_master/widgets/connection_icon_button.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<StatefulWidget> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final webviewKey = GlobalKey();
  
  InAppWebViewController? webViewController;
  final settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
    iframeAllow: "camera; microphone; geolocation; autoplay; encrypted-media;",
    iframeAllowFullscreen: true,
  );
  PullToRefreshController? pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = kDebugMode || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
        ? null 
        : PullToRefreshController(
          settings: PullToRefreshSettings(
            color: Colors.blue,
          ),
          onRefresh: () async {
            if (webViewController != null) {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController!.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController!.loadUrl(
                    urlRequest: URLRequest(url: await webViewController!.getUrl()));
              }
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final appViewmodel = Provider.of<AppViewmodel>(context, listen: true);

    if (appViewmodel.currentWebsite != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appViewmodel.currentWebsite!.name),
          actions: [
            ConnectionIconButton()
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webviewKey,
                initialUrlRequest: URLRequest(url: WebUri(appViewmodel.currentWebsite!.url)),
                initialSettings: settings,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    progress = 0;
                  });
                },
                onPermissionRequest: (controller, permissionRequest) async {
                  return PermissionResponse(
                    resources: permissionRequest.resources,
                    action: PermissionResponseAction.GRANT
                  );
                },
                onLoadStop: (controller, url) async {
                  if (pullToRefreshController != null) {
                    pullToRefreshController!.endRefreshing();
                  }
                  setState(() {
                    progress = 1;
                  });
                  controller.addJavaScriptHandler(handlerName: "clicked", callback: (el){
                    Logger().i("Element clicked", error: el);
                  });
                  await controller.injectJavascriptFileFromUrl(urlFile: WebUri("https://raw.githubusercontent.com/fshangala/lambo01_master/refs/heads/main/data/script.js"));
                },
                onReceivedError: (controller, request, error) {
                  if (pullToRefreshController != null) {
                    pullToRefreshController!.endRefreshing();
                  }
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  if (kDebugMode) {
                    print(consoleMessage.message);
                  }
                },
              ),
              progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: const Text("No website selected!"),
      );
    }
  }
}