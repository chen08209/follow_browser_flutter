import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../home/home.dart';
import '../webview/webview_panel.dart';

class TabPage extends StatefulWidget {
  final String id;

  const TabPage(this.id, {Key? key}) : super(key: key);

  @override
  State<TabPage> createState() => TabPageState();
}

class TabPageState extends State<TabPage> with NavigatorObserver {
  late BrowserModel browserModel;
  final GlobalKey _webKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      browserModel.currentContext = navigator?.context;
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    browserModel.currentRoute = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    browserModel.currentRoute = route.settings.name;
    super.didPush(route, previousRoute);
  }

  bool canBack() {
    if (_webKey.currentContext != null) {
      return Navigator.canPop(_webKey.currentContext!);
    }
    return false;
  }

  goBack() async {
    if (_webKey.currentContext != null) {
      await browserModel.currentController?.pause();
      Navigator.pop(_webKey.currentContext!);
    }
  }

  // Future<Uint8List?> getScreenshot() async {
  //   BrowserModel browserModel = context.read<BrowserModel>();
  //
  //   Uint8List? screenshot;
  //
  //   if (browserModel.currentRoute == '/web') {
  //     screenshot = await browserModel.currentController?.takeScreenshot(
  //       screenshotConfiguration: ScreenshotConfiguration(
  //           compressFormat: CompressFormat.JPEG, quality: 40),
  //     );
  //     // compressFormat: CompressFormat.JPEG, quality: 40)
  //   } else {
  //     RenderRepaintBoundary boundary = _repaintKey.currentContext
  //         ?.findRenderObject() as RenderRepaintBoundary;
  //     ui.Image image =
  //         await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
  //     ByteData? byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);
  //     screenshot = byteData?.buffer.asUint8List();
  //   }
  //
  //   return Future(() => screenshot);
  // }
  //
  // Future<void> pause() async {
  //   BrowserModel browserModel = context.read<BrowserModel>();
  //   BrowserTabModel currentTab = browserModel.getTabById(widget.id);
  //   currentTab.screenshot = await getScreenshot();
  //   // await currentTab.controller?.pause();
  // }

  @override
  Widget build(BuildContext context) {
    browserModel = context.watch<BrowserModel>();
    return Navigator(
      initialRoute: '/home',
      observers: [this],
      onGenerateRoute: (settings) {
        Widget panel;
        switch (settings.name) {
          case '/home':
            panel = const HomePanel();
            break;
          case '/webview':
            panel = WebViewPanel(
              key: _webKey,
            );
            break;
          default:
            panel = const HomePanel();
            break;
        }
        return PageRouteBuilder(
            settings: settings,
            pageBuilder: (
              context,
              animation,
              secondaryAnimation,
            ) {
              return FadeTransition(
                opacity: animation,
                child: panel,
              );
            });
      },
    );
  }
}
