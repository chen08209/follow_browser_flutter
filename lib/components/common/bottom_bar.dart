import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class BottomBar extends StatefulWidget {
  final double? progress;
  final List<Widget>? items;

  const BottomBar(
      {this.items, this.progress, Key? key})
      : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  double progressHeight = 2.5;

  @override
  void initState() {
    super.initState();
  }

  bool progressIsValid() {
    if(widget.progress == null){
      return false;
    }
    if (widget.progress! > 0 && widget.progress! < 1) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: progressHeight,
          child: Column(
            children: [
              AnimatedContainer(
                alignment: Alignment.topLeft,
                duration: const Duration(milliseconds: 200),
                height: progressIsValid() ? progressHeight : 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  value: widget.progress,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 0, 0, progressHeight),
            child: SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.items ?? [],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomBarItem extends StatelessWidget {
  final Widget? child;
  final void Function()? onTap;

  const BottomBarItem({this.child, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
