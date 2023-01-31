import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'components/components.dart';
import 'components/tab/tab_page.dart';
import 'components/tab/tab_viewer.dart';
import 'model/model.dart';
import 'utils/utils.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key}) : super(key: key);

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  int? preTime;

  List<ThemeModeButton> themeModeButtonList = [
    ThemeModeButton(
      describe: "跟随系统",
      icon: const Icon(FontIcons.auto),
      value: 'system',
    ),
    ThemeModeButton(
      describe: "浅色模式",
      icon: const Icon(FontIcons.sun),
      value: 'light',
    ),
    ThemeModeButton(
      describe: "深色模式",
      icon: const Icon(FontIcons.moon),
      value: 'dark',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BrowserModel browserModel = context.read<BrowserModel>();
      if (browserModel.tabList.isEmpty) {
        browserModel.addNewTab();
      }
    });
  }

  _openViewer(BuildContext context) {
    customShowBottomSheet(
      context: context,
      horizontalPadding: 0,
      child: const TabViewer(),
    );
  }

  _pushIntercept(String name) async {
    BrowserModel browserModel = context.read<BrowserModel>();
    if (browserModel.currentRoute != '/webview' ||
        (browserModel.currentController != null &&
            !(await browserModel.currentController!.isLoading()))) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (browserModel.currentController != null) {
        try {
          await browserModel.currentController!.pause();
        } catch (_) {}
      }
      if (mounted) {
        Navigator.of(context).pushNamed(name);
      }
    }
  }

  Widget _buildContent({
    required int index,
    required List<BrowserTabModel> items,
  }) {
    return IndexedStack(
      index: index,
      children: items
          .map(
            (e) => TabPage(
              e.id,
              key: GlobalObjectKey(e.id),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomBar(BrowserModel browserModel) {
    BottomBar bottomBar;
    Widget tabView = Stack(
      alignment: Alignment.center,
      children: [
        const Icon(FontIcons.container),
        Align(
          child: Text(
            browserModel.tabList.length.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        )
      ],
    );
    Widget menu = BottomBarItem(
      onTap: () {
        BuildContext context = CommonUtil.navigatorKey.currentContext!;
        customShowBottomSheet(
          context: CommonUtil.navigatorKey.currentContext!,
          child: Menu(
            items: [
              Button(
                describe: '书签',
                onTap: () {
                  _pushIntercept("/bookmark");
                },
                child: const Icon(FontIcons.starList),
              ),
              Button(
                describe: '历史',
                onTap: () {
                  _pushIntercept("/history");
                },
                child: const Icon(FontIcons.history),
              ),
              Consumer(builder: (_, Cache cache, __) {
                return Button(
                  describe: '深色模式',
                  onTap: () {
                    Navigator.of(context).pop();
                    customShowBottomSheet(
                      context: context,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 24,
                            ),
                            child: const Text(
                              "深色模式",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: themeModeButtonList
                                .map((e) => Button2(
                                      describe: e.describe,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        cache.themeMode = e.value;
                                      },
                                      color: e.value == cache.themeMode
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant
                                          : null,
                                      child: e.icon,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(FontIcons.moon),
                );
              }),
              Button(
                onTap: () {},
                describe: '桌面模式',
                child: const Icon(FontIcons.desktop),
              ),
              Button(
                onTap: () {},
                describe: '无痕模式',
                child: const Icon(FontIcons.inprivate),
              ),
              Button(
                onTap: () {
                  Navigator.of(context).pop();
                  _openViewer(context);
                },
                describe: '多窗口',
                child: tabView,
              ),
            ],
          ),
        );
      },
      child: const Icon(FontIcons.list),
    );
    if (browserModel.currentRoute == '/webview') {
      bottomBar = BottomBar(
        progress: browserModel.currentProgress,
        items: [
          BottomBarItem(
            onTap: () {
              _openViewer(context);
            },
            child: tabView,
          ),
          BottomBarItem(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Text(
                modString(browserModel.currentTitle == null
                    ? browserModel.currentUrl.toString()
                    : browserModel.currentTitle!),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          menu,
        ],
      );
    } else {
      bottomBar = BottomBar(
        items: [
          menu,
        ],
      );
    }

    return bottomBar;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Selector<BrowserModel, Tuple2<List<BrowserTabModel>, int?>>(
        selector: (context, browserModel) =>
            Tuple2(browserModel.tabList, browserModel.currentIndex),
        shouldRebuild: (pre, next) {
          return pre.item1.length != next.item1.length ||
              pre.item2 != next.item2;
        },
        child: Consumer(builder: (_, BrowserModel browserModel, ___) {
          return _buildBottomBar(browserModel);
        }),
        builder: (_, data, child) {
          return Layout(
            content: _buildContent(
              index: data.item2 ?? 0,
              items: data.item1,
            ),
            bottomBar: child,
          );
        },
      ),
      onWillPop: () async {
        BrowserModel browserModel = context.read<BrowserModel>();
        bool? webCanBack;
        try {
          webCanBack = await browserModel.currentController?.canGoBack();
        } catch (_) {
          webCanBack = false;
        }

        if (webCanBack ?? false) {
          browserModel.currentController!.goBack();
          return false;
        }

        TabPageState? tabState = GlobalObjectKey(browserModel.currentId!)
            .currentState as TabPageState?;

        if (tabState?.canBack() ?? false) {
          tabState?.goBack();
          return false;
        }

        int now = DateTime.now().millisecondsSinceEpoch;

        if (preTime == null) {
          preTime = now;
          if (mounted) {
            Toast.makeContent(context, const Text("再按一次退出浏览器")).show();
          }
          return false;
        } else {
          if (now - preTime! > 2000) {
            preTime = now;
            if (mounted) {
              Toast.makeContent(context, const Text("再按一次退出浏览器")).show();
            }
            return false;
          } else {
            return true;
          }
        }
      },
    );
  }
}

class ThemeModeButton {
  final String describe;

  final Icon icon;

  final String value;

  ThemeModeButton({
    required this.describe,
    required this.icon,
    required this.value,
  });
}

class ContentState {
  List<BrowserTabModel> tabList = [];
  String? currentId;

  ContentState({required List<BrowserTabModel> tabList, String? currentId});
}
