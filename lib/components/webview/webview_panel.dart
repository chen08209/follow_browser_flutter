import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../utils/common_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/model.dart';
import '../bookmark_history/bookmark_history.dart';
import '../common/common.dart';

class WebViewPanel extends StatefulWidget {
  const WebViewPanel({Key? key}) : super(key: key);

  @override
  State<WebViewPanel> createState() => WebViewPanelState();
}

class WebViewPanelState extends State<WebViewPanel> {
  bool _isLoading = false;

  late Future future;

  _start() {
    BrowserModel browserModel = context.read<BrowserModel>();
    browserModel.currentTitle = null;
    browserModel.currentProgress = 0;
    _isLoading = true;
    _work();
  }

  _work() {
    future = Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isLoading) return;
      if (mounted) {
        BrowserModel browserModel = context.read<BrowserModel>();
        browserModel.currentProgress = _inc(browserModel.currentProgress ?? 0);
        _work();
      }
    });
  }

  double _inc(double n) {
    double amount;
    if (n >= 0 && n < 0.2) {
      amount = 0.1;
    } else if (n >= 0.2 && n < 0.5) {
      amount = 0.05;
    } else if (n >= 0.5 && n < 0.8) {
      amount = 0.02;
    } else if (n >= 0.8 && n < 0.95) {
      amount = 0.01;
    } else {
      amount = 0;
    }
    return n + amount;
  }

  _done() {
    BrowserModel browserModel = context.read<BrowserModel>();
    _isLoading = true;
    browserModel.currentProgress = 1;
  }

  Widget _buildToast(WebUri url) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        const Text("将打开外部应用,是否运行？"),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: CommonUtil.defaultPadding),
          child: GestureDetector(
            onTap: () {
              launchUrl(
                url,
              );
            },
            child: Text(
              "允许",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    BrowserModel browserModel = context.read<BrowserModel>();
    Cache cache = context.read<Cache>();

    ForceDark forceDark = Theme.of(context).brightness == Brightness.dark
        ? ForceDark.ON
        : ForceDark.OFF;

    InAppWebViewSettings inAppWebViewSettings = InAppWebViewSettings(
      supportMultipleWindows: true,
      algorithmicDarkeningAllowed: true,
      forceDark: forceDark,
    );

    if (browserModel.currentController != null) {
      browserModel.currentController!
          .getSettings()
          .then(
            (value) => {
              if (value != inAppWebViewSettings)
                {
                  browserModel.currentController!
                      .setSettings(settings: inAppWebViewSettings)
                }
            },
          )
          .onError((error, stackTrace) => {});
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(url: browserModel.currentTab?.url),
      initialSettings: inAppWebViewSettings,
      onWebViewCreated: (controller) async {
        browserModel.currentController = controller;
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var url = navigationAction.request.url;
        if (url != null &&
            !["http", "https", "file", "chrome", "data", "javascript", "about"]
                .contains(url.scheme)) {
          canLaunchUrl(url).then((value) {
            if (value) {
              Toast.makeContent(context, _buildToast(url)).show();
            }
          });
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onLoadStart: (controller, url) async {
        if (url?.rawValue != null) {
          browserModel.currentUrl = WebUri((url?.rawValue)!);
        } else {
          browserModel.currentUrl = null;
        }
        List<Favicon> favicons;
        try {
          favicons = await controller.getFavicons();
        } catch (e) {
          favicons = [];
        }
        Favicon? favicon;

        if (favicons.isNotEmpty) {
          for (var fav in favicons) {
            if (fav.url.toString().endsWith('favicon.ico') ||
                fav.url.toString().endsWith('favicon64.ico')) {
              favicon = fav;
              break;
            }
          }
        }
        if (favicon != null) {
          Uint8List? faviconToUint8List;
          NetworkAssetBundle(favicon.url)
              .load(favicon.url.rawValue)
              .then((value) {
            faviconToUint8List = value.buffer.asUint8List();
          }).catchError((_) {
            faviconToUint8List = null;
          });
          browserModel.currentFavicon = faviconToUint8List;
        }
      },
      onTitleChanged: (controller, title) {
        if (browserModel.currentTab?.title != title) {
          browserModel.currentTitle = title;
          cache.addHistoryRecord(HistoryRecord(
            url: browserModel.currentUrl?.rawValue,
            title: browserModel.currentTitle,
            createTime: DateTime.now(),
            favicon: browserModel.currentFavicon,
          ));
        }
      },
      onProgressChanged: (controller, progress) async {
        if (!_isLoading && progress != 100) {
          _start();
        } else if (progress == 100) {
          _done();
        }
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      onCreateWindow: (controller, action) async {
        return null;
      },
      onEnterFullscreen: (controller) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
      },
      onExitFullscreen: (controller) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
    );
  }
}
