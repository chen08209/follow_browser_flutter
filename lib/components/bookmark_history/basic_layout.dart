import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class BasicLayout extends StatefulWidget {
  final Widget content;
  final Function(String value)? input;
  final String? placeholderSupplement;

  const BasicLayout({
    required this.content,
    this.input,
    this.placeholderSupplement,
    Key? key,
  }) : super(key: key);

  @override
  State<BasicLayout> createState() => _BasicLayoutState();
}

class _BasicLayoutState extends State<BasicLayout> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  GlobalKey buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _controller.addListener(() {
      if (widget.input != null) {
        widget.input!(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  unFocus() {
    _focusNode.unfocus();
  }

  double getTextButtonWidth() {
    final RenderBox renderContainer =
    buttonKey.currentContext?.findRenderObject() as RenderBox;
    return renderContainer.size.width;
  }

  @override
  Widget build(BuildContext context) {
    String hintText = "搜索 ${widget.placeholderSupplement}";
    InputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(width: 0, color: Colors.transparent),
      borderRadius: BorderRadius.circular(12),
      gapPadding: 0,
    );

    return Column(
      children: [
        LayoutBuilder(builder: (_, container) {
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: CommonUtil.defaultPadding,
              horizontal: CommonUtil.defaultPadding * 2,
            ),
            width: container.maxWidth,
            height: 72,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  right: 0,
                  child: TextButton(
                    key: buttonKey,
                    onPressed: () {
                      unFocus();
                    },
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Positioned(
                  child: TweenAnimationBuilder(
                    tween: Tween(
                      begin: container.maxWidth,
                      end: _focusNode.hasFocus
                          ? container.maxWidth - getTextButtonWidth() - 48
                          : container.maxWidth,
                    ),
                    duration: kThemeAnimationDuration,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Container(
                        alignment: Alignment.center,
                        width: value,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: child,
                      );
                    },
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: border,
                        enabledBorder: border,
                        hintText: hintText,
                        focusedBorder: border,
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: const Icon(FontIcons.search),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }),
        Expanded(
          child: widget.content,
        )
      ],
    );
  }
}
