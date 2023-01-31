import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class TabBar extends StatelessWidget {
  final Widget content;
  const TabBar({required this.content,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.expand,
      children: [
        Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints.expand(),
          child: content,
        ),
        Positioned(
          left: CommonUtil.defaultPadding + 4,
          child: IconButton(
            icon: const Icon(
              FontIcons.arrowLeft,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }
}

