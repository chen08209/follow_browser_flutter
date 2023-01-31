import 'package:flutter/material.dart';

class KeyboardDetector extends StatefulWidget {
  final Function? onVisible;

  final Function? onHidden;

  final Widget child;

  const KeyboardDetector(
      {required this.child, this.onVisible, this.onHidden, Key? key})
      : super(key: key);

  @override
  State<KeyboardDetector> createState() => _KeyboardDetectorState();
}

class _KeyboardDetectorState extends State<KeyboardDetector>
    with WidgetsBindingObserver {

  bool keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final double viewInsetsBottom = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets,
      WidgetsBinding.instance.window.devicePixelRatio,
    ).bottom;

    if (viewInsetsBottom == 0) {
      if (keyboardVisible) {
        keyboardVisible = false;
        onHidden();
      }
    } else {
      if (!keyboardVisible) {
        keyboardVisible = true;
        onVisible();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void onVisible() {
    if (widget.onVisible != null) {
      widget.onVisible!();
    }
  }

  void onHidden() {
    if (widget.onHidden != null) {
      widget.onHidden!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
