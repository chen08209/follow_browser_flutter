import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/utils.dart';

class Layout extends StatefulWidget {
  final Widget? tabBar;
  final Widget content;
  final Widget? bottomBar;
  final bool? enableMaterialBackground;

  const Layout({
    this.tabBar,
    required this.content,
    this.bottomBar,
    this.enableMaterialBackground = true,
    Key? key,
  }) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  ScreenUtil screenUtil = ScreenUtil.getInstance();

  Widget content() {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: SafeArea(
        minimum: ScreenUtil.getCurrentStatusBarH(context) == 0
            ? ScreenUtil.getMediaQueryData(context).systemGestureInsets
            : EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.tabBar != null
                ? SizedBox(
              height: kToolbarHeight,
              child: widget.tabBar,
            )
                : Container(),
            Expanded(child: widget.content),
            widget.bottomBar != null
                ? SizedBox(
              height: CommonUtil.bottomBarHeight,
              child: widget.bottomBar,
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableMaterialBackground!) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: content(),
      );
    } else {
      return Material(
        child: content(),
      );
    }
  }
}
