import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../utils/utils.dart';

class BrowserModel with ChangeNotifier {
  List<BrowserTabModel> tabList = [];

  String? _currentId;

  BrowserModel({List<BrowserTabModel>? tabList}) {
    if (tabList != null) {
      tabList = tabList;
    }
  }

  addNewTab() {
    tabList.add(BrowserTabModel());
    _currentId = tabList.last.id;
    notifyListeners();
  }

  getTabById(String id) {
    for (int i = 0; i < tabList.length; i++) {
      if (tabList[i].id == id) {
        return tabList[i];
      }
    }
  }

  removeTabById(String id) {
    for (int i = 0; i < tabList.length; i++) {
      if (tabList[i].id == id) {
        if (tabList.length != 1) {
          if (tabList[i].id == _currentId) {
            int nextIndex = i - 1 < 0 ? 1 : i - 1;
            _currentId = tabList[nextIndex].id;
          }
          tabList.remove(tabList[i]);
        } else {
          tabList.remove(tabList[i]);
          _currentId = null;
        }
        notifyListeners();
      }
    }
  }

  search({required String searchApi, required String value}) {
    if (!urlReg.hasMatch(value)) {
      currentTab?.keyword = value;
      value = searchApi.replaceFirst(keyWordReg, value);
    }


    explore(url: value);
  }

  explore({required String url}) {
    WebUri webUri = WebUri(url);
    if (currentRoute != '/webview') {
      currentTab?.url = webUri;
      Navigator.of(currentContext!).pushNamed("/webview");
    } else {
      currentController?.loadUrl(urlRequest: URLRequest(url: webUri));
    }
  }

  String? get currentId => _getCurrentId();

  String? _getCurrentId() {
    if (tabList.isEmpty) {
      return null;
    }
    if (tabList.length == 1) {
      return tabList[0].id;
    }
    return _currentId;
  }

  set currentId(String? value) {
    if (value != _currentId) {
      _currentId = value;
      notifyListeners();
    }
  }

  int? get currentIndex => _getCurrentIndex();

  int? _getCurrentIndex() {
    for (int i = 0; i < tabList.length; i++) {
      if (tabList[i].id == currentId) {
        return i;
      }
    }
    return null;
  }

  BrowserTabModel? get currentTab => _getCurrentTab();

  BrowserTabModel? _getCurrentTab() {
    if (tabList.isEmpty) {
      return null;
    }
    if (currentIndex == null) {
      return null;
    }
    return tabList[currentIndex!];
  }

  String? get currentKeyword => currentTab?.keyword;

  set currentKeyword(String? value) {
    if (value != currentTab?.keyword) {
      currentTab?.keyword = value;
      notifyListeners();
    }
  }

  WebUri? get currentUrl => currentTab?.url;

  set currentUrl(WebUri? value) {
    if (value != currentTab?.url) {
      currentTab?.url = value;
      notifyListeners();
    }
  }

  String? get currentTitle => currentTab?.title;

  set currentTitle(String? value) {
    if (value != currentTab?.title) {
      currentTab?.title = value;
      notifyListeners();
    }
  }

  Uint8List? get currentFavicon => currentTab?.favicon;

  set currentFavicon(Uint8List? value) {
    if (value != currentTab?.favicon) {
      currentTab?.favicon = value;
      notifyListeners();
    }
  }

  Uint8List? get currentScreenshot => currentTab?.screenshot;

  set screenshot(Uint8List? value) {
    if (value != currentTab?.screenshot) {
      currentTab?.screenshot = value;
      notifyListeners();
    }
  }

  InAppWebViewController? get currentController => currentTab?.controller;

  set currentController(InAppWebViewController? value) {
    if (value != currentTab?.controller) {
      currentTab?.controller = value;
      notifyListeners();
    }
  }

  double? get currentProgress => currentTab?.progress;

  set currentProgress(double? value) {
    if (value != currentTab?.progress) {
      currentTab?.progress = value;
      notifyListeners();
    }
  }

  String? get currentRoute => currentTab?.route;

  set currentRoute(String? value) {
    if (value != currentTab?.route) {
      currentTab?.route = value;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  BuildContext? get currentContext => currentTab?.context;

  set currentContext(BuildContext? value) {
    if (value != currentTab?.context) {
      currentTab?.context = value;
      notifyListeners();
    }
  }
}

class BrowserTabModel with ChangeNotifier {
  String id = UniqueKey().toString();
  String? keyword;
  WebUri? url;
  String? title;
  Uint8List? favicon;
  Uint8List? screenshot;
  InAppWebViewController? controller;
  double? progress;
  String secondaryId = '';
  String? route;
  BuildContext? context;

  BrowserTabModel() {
    secondaryId = "secondary-$id";
  }
}
