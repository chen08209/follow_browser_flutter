import 'dart:convert';

import 'package:flutter/material.dart';

import '../components/bookmark_history/bookmark_history.dart';
import '../utils/utils.dart';

class Cache with ChangeNotifier {
  Cache({
    List<String>? searchRecords,
    String? historyRecords,
    String? bookMarks,
    String? themeMode,
  }) {
    _themeMode = themeMode ?? 'system';
    _searchRecords = searchRecords ?? [];
    List historyMap = [];
    if (historyRecords != null) {
      historyMap = json.decode(historyRecords);
    }
    _historyRecords = historyMap.map((e) => HistoryRecord.fromMap(e)).toList();

    List bookMarksMap = [];
    if (bookMarks != null) {
      bookMarksMap = json.decode(bookMarks);
    }
    _bookMarks = bookMarksMap.map((e) => BookMark.fromMap(e)).toList();
  }

  //搜索记录
  late List<String> _searchRecords;

  List<String> get searchRecords => _searchRecords;

  addSearchRecord(String searchRecord) {
    // if (_searchRecord.isEmpty) {
    //   _addSearchRecord(value);
    // } else {
    //   int index = _searchRecord.indexOf(value);
    //   if (index != -1) {
    //     _searchRecord.removeAt(index);
    //   }
    //   if (_searchRecord.length == 10) {
    //     _searchRecord.removeAt(0);
    //   }
    //   _addSearchRecord(value);
    // }

    int index = _searchRecords.indexOf(searchRecord);
    if (index != -1) {
      _searchRecords.removeAt(index);
    }
    if (_searchRecords.length == 10) {
      _searchRecords.removeAt(0);
    }
    _searchRecords.add(searchRecord);
    notifyListeners();
    PreferencesUtil.preferences.setStringList("searchRecords", _searchRecords);
  }

  //主题模式
  late String _themeMode;

  String get themeMode => _themeMode;

  set themeMode(String value) {
    if (value != _themeMode) {
      _themeMode = value;
      notifyListeners();
      PreferencesUtil.preferences.setString("themeMode", _themeMode);
    }
  }

  //历史记录
  late List<HistoryRecord> _historyRecords;

  List<HistoryRecord> get historyRecords => _historyRecords;

  List<HistoryRecord> getHistoryRecordsWithTitle(String title) {
    return historyRecords
        .where((element) => element.title?.contains(title) ?? false)
        .toList();
  }

  addHistoryRecord(HistoryRecord historyRecord) {
    int index = _historyRecords.indexOf(historyRecord);
    if (index != -1) {
      _historyRecords.removeAt(index);
    }
    _historyRecords.add(historyRecord);
    notifyListeners();
    PreferencesUtil.preferences.setString(
      "historyRecords",
      json.encode(_historyRecords),
    );
  }

  //书签
  late List<BookMark> _bookMarks;

  List<BookMark> get bookMarks => _bookMarks;

  List<BookMark> getBookMarksByPid([String value = 'root']) {
    return bookMarks.where((element) => element.pid == value).toList();
  }

  List<BookMark> getBookMarksWithTitleByPid(String title,
      [String value = 'root']) {
    return bookMarks
        .where((element) => element.pid == value)
        .toList()
        .where((element) => element.title?.contains(title) ?? false)
        .toList();
  }

  addBookMarks(List<BookMark> bookMarks) {
    for (int i = 0; i < bookMarks.length; i++) {
      BookMark bookMark = bookMarks[i];
      int index = _bookMarks.indexOf(bookMark);
      if (index != -1) {
        BookMark currentBookMark = _bookMarks[index];
        if (bookMark is Link) {
          (currentBookMark as Link).update(bookMark);
        } else {
          List<BookMark> subBookMarks =
          bookMarks.where((e) => e.pid == bookMark.id).toList();
          for (var e in subBookMarks) {
            e.pid = currentBookMark.pid;
          }
          addBookMarks(subBookMarks);
        }
      } else {
        _bookMarks.add(bookMark);
      }
    }
    notifyListeners();
    PreferencesUtil.preferences.setString(
      "bookMarks",
      json.encode(_bookMarks),
    );
  }
}
