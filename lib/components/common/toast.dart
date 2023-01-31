import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../utils/utils.dart';

class Toast {
  static const Duration duration = Duration(milliseconds: 2000);
  static const Duration animatedDuration = Duration(milliseconds: 400);
  bool _showing = false;
  OverlayEntry? _overlayEntry;

  BuildContext _context;
  Duration _duration;
  late Widget _content;

  Toast._(this._context, this._duration, this._content);

  factory Toast.makeContent(
    BuildContext context,
    Widget content, {
    Duration duration = duration,
  }) {
    return Toast._(context, duration, content);
  }

  OverlayEntry _buildToast() {
    return OverlayEntry(builder: (context) {
      Size size = MediaQuery.of(context).size;
      return Positioned(
        top: size.height * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            width: size.width,
            child: _buildContent(),
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    return AnimatedOpacity(
      opacity: _showing ? 1.0 : 0.0,
      duration: animatedDuration,
      onEnd: (){
        if(_overlayEntry != null && _showing == false){
          _overlayEntry?.remove();
        }
      },
      child: Card(
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(_context).colorScheme.surfaceVariant,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: EdgeInsets.all(CommonUtil.defaultPadding),
          child: _content,
        ),
      ),
    );
  }

  show() {
    _overlayEntry = _buildToast();
    Overlay.of(_context)?.insert(_overlayEntry!);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _showing = true;
      _overlayEntry!.markNeedsBuild();
    });
    Future.delayed(_duration - animatedDuration, () {
      _showing = false;
      _overlayEntry!.markNeedsBuild();
      // entry.remove();
    });
  }
}
