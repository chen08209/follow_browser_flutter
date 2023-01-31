import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/bookmark_history/basic_layout.dart';
import 'package:provider/provider.dart';

import '../../model/model.dart';
import '../../utils/utils.dart';
import 'common_item.dart';
import 'history.dart';

class HistoryPanel extends StatefulWidget {
  const HistoryPanel({Key? key}) : super(key: key);

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  String? condition;
  final HoverVmHeader _hoverVmHeader = HoverVmHeader();
  late Map<DateTime, List<HistoryRecord>> sectionMap;
  late List<DateTime> sectionMapKeys;
  final double headerHeight = 32;
  final ScrollController _controller = ScrollController();
  final List<SectionInfo> _sectionInfoList = [];
  int _currentIndex = 0;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    Cache cache = context.read<Cache>();
    _initSection(cache);
    _controller.addListener(() {
      _adjustHeader(_controller.offset);
    });
  }

  _initSection(Cache cache) {
    List<HistoryRecord> historyRecords;
    if (condition != null && condition!.isNotEmpty) {
      historyRecords = cache.getHistoryRecordsWithTitle(condition!);
    } else {
      historyRecords = cache.historyRecords;
    }
    sectionMap = _getHistorySectionMap(historyRecords);
    sectionMapKeys = sectionMap.keys.toList();
    if (sectionMapKeys.isNotEmpty) {
      _hoverVmHeader.vmKey = sectionMapKeys[0];
      _computeSectionInfo(sectionMapKeys, sectionMap);
    } else {
      _hoverVmHeader.vmKey = null;
    }
  }

  _computeSectionInfo(
      List<DateTime> keys, Map<DateTime, List<HistoryRecord>> items) {
    _sectionInfoList.clear();
    double totalOffset = 0;
    for (var i = 0; i < keys.length; i++) {
      DateTime key = keys[i];
      List<HistoryRecord>? item = items[key];
      if (item?.length != null) {
        double startOffset = totalOffset;
        double headerEndOffset = totalOffset + headerHeight;
        double itemsHeight = item!.length * CommonItem.height;

        totalOffset += headerHeight + itemsHeight;

        _sectionInfoList.add(SectionInfo(
            key: key,
            startOffset: startOffset,
            headerEndOffset: headerEndOffset));
      }
    }
  }

  _adjustHeader(double offset) {
    offset = offset + headerHeight;
    bool downward = offset - _lastOffset > 0;
    _lastOffset = offset;
    SectionInfo currentSectionInfo = _sectionInfoList[_currentIndex];
    if (downward) {
      SectionInfo nextSectionInfo =
          _currentIndex + 1 > _sectionInfoList.length - 1
              ? _sectionInfoList[_sectionInfoList.length - 1]
              : _sectionInfoList[_currentIndex + 1];
      if (offset < nextSectionInfo.startOffset) {
        _hoverVmHeader.vmKey = currentSectionInfo.key;
        _hoverVmHeader.vmHeaderToTop = 0;
      } else if (offset > nextSectionInfo.headerEndOffset) {
        _currentIndex++;
        if (_currentIndex > _sectionInfoList.length - 1) {
          _currentIndex = _sectionInfoList.length - 1;
        }
        _hoverVmHeader.vmKey = nextSectionInfo.key;
        _hoverVmHeader.vmHeaderToTop = 0;
      } else {
        _hoverVmHeader.vmKey = currentSectionInfo.key;
        _hoverVmHeader.vmHeaderToTop = offset - nextSectionInfo.startOffset;
      }
    } else {
      SectionInfo prevSectionInfo = _currentIndex - 1 < 0
          ? _sectionInfoList[0]
          : _sectionInfoList[_currentIndex - 1];
      if (offset > currentSectionInfo.headerEndOffset) {
        _hoverVmHeader.vmKey = currentSectionInfo.key;
        _hoverVmHeader.vmHeaderToTop = 0;
      } else if (offset < currentSectionInfo.startOffset) {
        _currentIndex--;
        if (_currentIndex < 0) {
          _currentIndex = 0;
        }
        _hoverVmHeader.vmKey = prevSectionInfo.key;
        _hoverVmHeader.vmHeaderToTop = 0;
      } else {
        _hoverVmHeader.vmKey = prevSectionInfo.key;
        _hoverVmHeader.vmHeaderToTop = offset - currentSectionInfo.startOffset;
      }
    }
  }

  String _titleFormat(DateTime dateTime) {
    if (dateTime.day == DateTime.now().day) {
      return "今天";
    } else {
      return DateFormat("yyyy-MM-dd EE", "zh_CN").format(dateTime);
    }
  }

  Widget _buildHeader(DateTime key, [double bottom = 0]) {
    return LayoutBuilder(builder: (_, container) {
      Widget content = Container(
        width: container.maxWidth,
        height: headerHeight,
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.symmetric(
          horizontal: CommonUtil.defaultPadding * 2,
          vertical: 4,
        ),
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.center,
          children: [
            Container(
              height: headerHeight - 8,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: headerHeight - 16,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(
                    _titleFormat(key),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      if (bottom != 0) {
        return Stack(
          children: [
            Positioned(
              top: -bottom,
              child: content,
            )
          ],
        );
      } else {
        return content;
      }
    });
  }

  SliverList _buildSection(DateTime key, List<HistoryRecord> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: items.length + 1,
        (context, index) {
          if (index == 0) {
            return _buildHeader(key);
          } else {
            HistoryRecord item = items[index - 1];
            return InkWell(
              onTap: () {
                BrowserModel browserModel = context.read<BrowserModel>();
                Navigator.pop(context);
                delayExec(() {
                  if (item.url != null) {
                    browserModel.explore(url: item.url!);
                  }
                });
              },
              child: CommonItem(item),
            );
          }
        },
      ),
    );
  }

  Map<DateTime, List<HistoryRecord>> _getHistorySectionMap(
    List<HistoryRecord> historyItems,
  ) {
    List<HistoryRecord> items = historyItems.reversed.toList();
    Map<DateTime, List<HistoryRecord>> historySectionMap = {};
    if (items.isNotEmpty) {
      int tempIndex = 0;
      DateTime tempDate = items[0].createTime;
      for (int i = 0; i < items.length; i++) {
        HistoryRecord item = items[i];
        if (tempDate.day != item.createTime.day) {
          List<HistoryRecord> historySection =
              items.getRange(tempIndex, i).toList();
          historySectionMap[tempDate] = historySection;
          tempDate = item.createTime;
          tempIndex = i;
        }
      }
      List<HistoryRecord> historySection =
          items.getRange(tempIndex, items.length).toList();
      historySectionMap[tempDate] = historySection;
    }

    return historySectionMap;
  }

  @override
  Widget build(BuildContext context) {
    Cache cache = context.watch<Cache>();

    return BasicLayout(
      placeholderSupplement: "历史",
      input: (value) {
        condition = value;
        setState(() {
          _initSection(cache);
        });
      },
      content: ChangeNotifierProvider.value(
        value: _hoverVmHeader,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _controller,
              slivers: sectionMapKeys
                  .map((e) => _buildSection(e, sectionMap[e] ?? []))
                  .toList(),
            ),
            Consumer(builder: (_, HoverVmHeader hoverVmHeader, ___) {
              if (hoverVmHeader.vmKey != null) {
                return _buildHeader(
                    hoverVmHeader.vmKey!, hoverVmHeader.vmHeaderToTop ?? 0);
              } else {
                return Container();
              }
            })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class HoverVmHeader extends ChangeNotifier {
  DateTime? _vmKey;
  double? _vmHeaderToTop;

  DateTime? get vmKey => _vmKey;

  set vmKey(DateTime? value) {
    if (value != _vmKey) {
      _vmKey = value;
      notifyListeners();
    }
  }

  double? get vmHeaderToTop => _vmHeaderToTop;

  set vmHeaderToTop(double? value) {
    if (value != _vmHeaderToTop) {
      _vmHeaderToTop = value;
      notifyListeners();
    }
  }
}

class SectionInfo {
  DateTime key;
  double startOffset;
  double headerEndOffset;

  SectionInfo({
    required this.key,
    required this.startOffset,
    required this.headerEndOffset,
  });
}
