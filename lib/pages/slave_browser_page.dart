import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lambo01_master/models/message_model.dart';
import 'package:lambo01_master/viewmodels/app_viewmodel.dart';
import 'package:lambo01_master/widgets/connection_icon_button.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

class SlaveBrowserPage extends StatefulWidget {
  const SlaveBrowserPage({super.key});

  @override
  State<StatefulWidget> createState() => _SlaveBrowserPageState();
}

class _SlaveBrowserPageState extends State<SlaveBrowserPage> {
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
    AppViewmodel appViewmodel = Provider.of<AppViewmodel>(context, listen: false);

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
    
    appViewmodel.messageStream?.listen((message) {
      if (webViewController != null) {
        Logger().i("Message sent to WebView", error: message);
      }
    });
  }

  @override
  void dispose() {
    webViewController?.dispose();
    pullToRefreshController?.dispose();
    super.dispose();
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
                  controller.addJavaScriptHandler(handlerName: "clicked", callback: (data) {
                    appViewmodel.sendMessage(
                      MessageModel(
                        eventType: 'mouse', 
                        event: 'click', 
                        args: List<String>.from(data), 
                        kwargs: {}
                      )
                    );
                    Logger().i("Click handler called", error: data);
                  });
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
                  await controller.evaluateJavascript(source: appViewmodel.appData!.scriptSource);
                  await controller.evaluateJavascript(source: "LamboScript.init();");
                  Logger().i("Page loaded: $url");
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