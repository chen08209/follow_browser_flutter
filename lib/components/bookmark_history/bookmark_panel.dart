import 'package:flutter/material.dart';
import '../../components/bookmark_history/bookmark_history.dart';
import '../../components/bookmark_history/common_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../model/model.dart';
import '../../utils/utils.dart';
import 'basic_layout.dart';

class BookMarkPanel extends StatefulWidget {
  const BookMarkPanel({Key? key}) : super(key: key);

  @override
  State<BookMarkPanel> createState() => _BookMarkPanelState();
}

class _BookMarkPanelState extends State<BookMarkPanel> {
  String? condition;
  late List<BookMark> result;
  final List<BookMarkRoute> _bookMarkRouter = [
    BookMarkRoute(title: '书签', pid: 'root')
  ];

  Widget _buildFolderItem(Folder folder) {
    return Container(
      height: CommonItem.height,
      padding: EdgeInsets.symmetric(
        vertical: CommonUtil.defaultPadding,
        horizontal: CommonUtil.defaultPadding * 2,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: CommonUtil.defaultPadding),
            child: SvgPicture.asset(
              AssetsUtil.folder,
              height: CommonItem.height - 24,
            ),
          ),
          Text(
            folder.title ?? '未知',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BookMark bookMark) {
    if (bookMark is Folder) {
      return InkWell(
        key: ValueKey(bookMark.id),
        onTap: () {
          setState(() {
            _bookMarkRouter
                .add(BookMarkRoute(title: bookMark.title, pid: bookMark.id));
          });
        },
        child: _buildFolderItem(bookMark),
      );
    } else {
      return InkWell(
        key: ValueKey(bookMark.id),
        child: CommonItem(bookMark),
        onTap: () {
          BrowserModel browserModel = context.read<BrowserModel>();
          Navigator.pop(context);
          delayExec(() {
            browserModel.explore(url: (bookMark as Link).url!);
          });
        },
      );
    }
  }

  _goBack() {
    setState(() {
      _bookMarkRouter.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    Cache cache = context.watch<Cache>();
    List<BookMark> bookMarks =
        cache.getBookMarksByPid(_bookMarkRouter.last.pid);

    if (condition != null && condition!.isNotEmpty) {
      result = cache.getBookMarksWithTitleByPid(
          condition!, _bookMarkRouter.last.pid);
    } else {
      result = bookMarks;
    }

    result.sort((a, b) {
      bool aIsFolder = a is Folder;
      bool bIsFolder = b is Folder;
      if (aIsFolder && !bIsFolder) {
        return -1;
      }
      if (!aIsFolder && bIsFolder) {
        return 1;
      }
      int compareTo = a.index - b.index;
      if (compareTo == 0) {
        return -1;
      } else {
        return a.index - b.index;
      }
    });
    Widget content;
    if (_bookMarkRouter.length > 1) {
      content = ListView.builder(
        itemCount: result.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              key: UniqueKey(),
              onTap: () {
                _goBack();
              },
              child: _buildFolderItem(
                Folder(title: '...', pid: UniqueKey().toString()),
              ),
            );
          }
          BookMark bookMark = result[index - 1];
          return _buildItem(bookMark);
        },
      );
    } else {
      content = ListView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          BookMark bookMark = result[index];
          return _buildItem(bookMark);
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_bookMarkRouter.length > 1) {
          _goBack();
          return false;
        }
        return true;
      },
      child: BasicLayout(
        placeholderSupplement: _bookMarkRouter.last.title,
        input: (value) {
          setState(() {
            condition = value;
          });
        },
        content: content,
      ),
    );
  }
}

class BookMarkRoute {
  String pid;
  String? title;

  BookMarkRoute({required this.pid, this.title});
}
