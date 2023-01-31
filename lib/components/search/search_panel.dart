import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../components.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';

class SearchPanel extends StatefulWidget {
  final Widget? title;

  final Widget? other;

  final bool? isTemp;

  final String? initValue;

  const SearchPanel({
    this.title,
    this.initValue,
    this.isTemp = false,
    this.other,
    Key? key,
  }) : super(key: key);

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  List suggestions = [];
  bool showDetail = false;

  @override
  void initState() {
    super.initState();

    controller.value = TextEditingValue(
      text: widget.initValue ?? '',
      selection: TextSelection.collapsed(
        offset: widget.initValue?.length ?? 0,
      ),
    );

    focusNode.addListener(() {
      if (focusNode.hasFocus == false) {
        if (controller.text.isNotEmpty) {
          controller.text = '';
        }
        // showDetail = false;
      }
      setState(() {});
    });

    Function setSuggestions = debounce(() {
      _getSuggestions(controller.text).then(
        (value) => setState(
          () {
            suggestions = value;
          },
        ),
      );
    });

    controller.addListener(() {
      setSuggestions();
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.isTemp!) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    controller.dispose();
  }

  Future<List> _getSuggestions(String val) async {
    var url = Uri.parse(CommonUtil.suggestionsApi + val);

    var response = await http.get(url);

    return Future(() => jsonDecode(response.body)[1]);
  }

  _clear() {
    controller.text = '';
  }

  _unfocus() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
      if (widget.isTemp ?? false) {
        Navigator.pop(context);
      }
    }
  }

  _submit({String? value}) {
    SettingModel settingModel = context.read<SettingModel>();
    BrowserModel browserModel = context.read<BrowserModel>();
    Cache cache = context.read<Cache>();
    if (value != null) {
      controller.text = value;
    }
    cache.addSearchRecord(controller.text);
    browserModel.search(
        searchApi: settingModel.searchApi, value: controller.text);
    _unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDetector(
      onHidden: () {
        _unfocus();
      },
      child: panelBuilder(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            focusNode.hasFocus
                ? showDetail
                    ? controller.text.isNotEmpty
                        ? Expanded(
                            child: SearchList(
                              suggestions: suggestions,
                              onItemTap: (val) {
                                _submit(value: val);
                              },
                            ),
                          )
                        : SearchRecord(
                            onTab: (val) {
                              _submit(value: val);
                            },
                          )
                    : Container()
                : widget.title ?? Container(),
            SearchBar(
              focusNode: focusNode,
              controller: controller,
              submit: () {
                _submit();
              },
              prefix: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.pets,
                  size: 24,
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
              suffix: LayoutBuilder(
                builder: (context, constraints) {
                  List<Widget> rowList = [];
                  if (focusNode.hasFocus == true) {
                    if (controller.text != '') {
                      rowList.add(
                        IconButton(
                          onPressed: () {
                            _clear();
                          },
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(
                            Icons.close,
                            size: 24,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                      rowList.add(
                        TextButton(
                          onPressed: () {
                            _submit();
                          },
                          child: const Text(
                            "搜索",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    } else {
                      rowList.add(
                        TextButton(
                          child: const Text(
                            "取消",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            _unfocus();
                          },
                        ),
                      );
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: rowList,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget panelBuilder({
    required BuildContext context,
    required Widget child,
  }) {
    Duration duration = const Duration(milliseconds: 300);
    Curve curve = Curves.easeOutSine;
    double screenHeight = ScreenUtil.getInstance().screenHeight -
        ScreenUtil.getInstance().statusBarHeight -
        ScreenUtil.getInstance().navigationBarHeight;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double searchBarHeight = CommonUtil.searchBarHeight;

    if (ScreenUtil.getCurrentScreenH(context) > 0) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double bottomBarHeight = screenHeight - constraints.maxHeight;
          double bottomToCenter = (constraints.maxHeight - searchBarHeight) / 2;
          if (widget.isTemp! == true) {
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: Duration.zero,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  bottom:
                      keyboardHeight - (screenHeight - constraints.maxHeight),
                  child: AnimatedPadding(
                    duration: duration,
                    curve: curve,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 8,
                    ),
                    child: child,
                  ),
                )
              ],
            );
          } else {
            return Stack(
              children: [
                TweenAnimationBuilder(
                  tween: Tween(
                    begin: bottomToCenter,
                    end: focusNode.hasFocus && keyboardHeight > 200
                        ? keyboardHeight - bottomBarHeight
                        : bottomToCenter,
                  ),
                  duration: duration,
                  curve: curve,
                  onEnd: () {
                    if (focusNode.hasFocus) {
                      setState(() {
                        showDetail = true;
                      });
                    } else {
                      setState(() {
                        showDetail = false;
                      });
                    }
                  },
                  child: AnimatedPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: focusNode.hasFocus ? 8 : 16,
                    ),
                    duration: duration,
                    curve: curve,
                    child: child,
                  ),
                  builder: (context, value, child) {
                    return Positioned(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      bottom: value,
                      child: child ?? Container(),
                    );
                  },
                )
              ],
            );
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
