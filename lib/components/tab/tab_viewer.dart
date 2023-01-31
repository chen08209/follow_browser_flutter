import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../model/model.dart';
import '../../utils/utils.dart';

class TabViewer extends StatefulWidget {

  const TabViewer({Key? key}) : super(key: key);

  @override
  State<TabViewer> createState() => _TabViewerState();
}

class _TabViewerState extends State<TabViewer> {
  late BrowserModel browserModel;
  late final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (browserModel.currentTab?.secondaryId != null) {
        Scrollable.ensureVisible(
            GlobalObjectKey((browserModel.currentTab?.secondaryId)!)
                .currentContext!);
      }
    });
  }

  _add() {
    Navigator.pop(context);
    browserModel.addNewTab();
  }

  _remove(String id) {
    browserModel.removeTabById(id);

    setState(() {
      browserModel = context.read<BrowserModel>();
    });

    if (browserModel.tabList.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _add();
      });
    }
  }

  pause() {
    if (browserModel.currentRoute == '/webview') {
      browserModel.currentController?.pause();
    }
  }

  resume() {
    if (browserModel.currentRoute == '/webview') {
      browserModel.currentController?.resume();
    }
  }

  _open(String id) {
    pause();
    Navigator.pop(context);
    browserModel.currentId = id;
    resume();
  }

  Widget _itemContent(BrowserTabModel item) {
    String title;
    Widget icon;
    if (item.route != '/web') {
      title = "主页";
      icon = const Icon(
        FontIcons.home,
        size: 24,
      );
    } else {
      title = item.title ?? '未知';
      icon = item.favicon != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                item.favicon!,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
            )
          : const Icon(
              FontIcons.earth,
              size: 24,
            );
    }
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: CommonUtil.defaultPadding * 2, left: CommonUtil.defaultPadding),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: browserModel.currentId == item.id
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: icon,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(right: CommonUtil.defaultPadding),
            child: Text(
              modString(title),
              style: browserModel.currentId == item.id
                  ? TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const TextStyle(
                      fontSize: 18,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BrowserTabModel item) {
    Widget content = Dismissible(
      key: GlobalObjectKey(item.secondaryId),
      onDismissed: (_) {
        _remove(item.id);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: CommonUtil.defaultPadding,
          vertical: CommonUtil.defaultPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: _itemContent(item),
            ),
            IconButton(
              onPressed: () {
                _remove(item.id);
              },
              icon: const Icon(
                FontIcons.close,
                size: 24,
              ),
            )
          ],
        ),
      ),
    );

    return InkWell(
      onTap: () {
        _open(item.id);
      },
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    browserModel = context.read<BrowserModel>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: browserModel.tabList.map((e) => _buildItem(e)).toList(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(FontIcons.add),
          onPressed: () {
            _add();
          },
        )
      ],
    );
  }
}
