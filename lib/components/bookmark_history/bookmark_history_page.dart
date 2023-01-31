import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../components/common/common.dart' as common;
import '../../utils/utils.dart';
import 'package:provider/provider.dart';
import 'bookmark_history.dart';
import '../../model/model.dart';
import 'bookmark_panel.dart';
import 'history_panel.dart';

class BookMarkHistoryPage extends StatefulWidget {
  final int? initialIndex;

  const BookMarkHistoryPage({this.initialIndex = 0, Key? key})
      : super(key: key);

  @override
  State<BookMarkHistoryPage> createState() => _BookMarkHistoryPageState();
}

class _BookMarkHistoryPageState extends State<BookMarkHistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _panels = ["书签", "历史"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initialIndex ?? 0,
      length: _panels.length,
      vsync: this,
    );
    _tabController.animation?.addListener(() {
      _unFocus();
    });
  }

  _unFocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Widget _tabBar(
    List<String> items,
  ) {
    ThemeUtil themeUtil = ThemeUtil(context);
    return TabBar(
        enableFeedback: true,
        labelPadding: kTabLabelPadding,
        labelStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        isScrollable: true,
        indicatorPadding: EdgeInsets.zero,
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Colors.transparent,
        labelColor: themeUtil.textPrimaryColor,
        unselectedLabelColor: themeUtil.textInactivationColor,
        // labelColor: Theme.of(context).colorScheme.primary,
        // unselectedLabelColor: Theme.of(context).colorScheme.primary.withOpacity(0.38),
        controller: _tabController,
        tabs: items.map((e) => Tab(text: e)).toList());
  }

  Widget _tabPanel(String e) {
    if (e == '历史') {
      return const HistoryPanel();
    } else {
      return const BookMarkPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return common.Layout(
      tabBar: common.TabBar(
        content: _tabBar(_panels),
      ),
      content: TabBarView(
        controller: _tabController,
        children: _panels
            .map(
              (e) => _tabPanel(e),
            )
            .toList(),
      ),
      bottomBar: common.BottomBar(
        items: [
          common.BottomBarItem(
            onTap: () async {
              Cache cache = context.read<Cache>();
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                  dialogTitle: '书签导入',
                  type: FileType.custom,
                  allowedExtensions: ['html']);
              if (result != null) {
                List<BookMark> bookMarks = getBookMarksFromHtmlStr(
                    await File(result.files.single.path!).readAsString());
                cache.addBookMarks(bookMarks);
              }
            },
            child: const Center(
              child: Text('书签导入'),
            ),
            // child: const Text('书签导入'),
          )
        ],
      ),
    );
  }
}
