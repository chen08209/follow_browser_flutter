import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

abstract class BookMark {
  String id = UniqueKey().toString();
  DateTime createTime = DateTime.now();
  String? title;
  int index = 0;
  late String pid;

  BookMark({required this.pid, required this.title});

  static BookMark fromMap(Map map) {
    if (map['url'] != null) {
      return Link.fromMap(map);
    } else {
      return Folder.fromMap(map);
    }
  }
}

class Folder extends BookMark {
  Folder({required super.title, required super.pid});

  Folder.fromMap(Map map)
      : super(
          pid: map['pid'],
          title: map["title"],
        ) {
    id = map["id"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "pid": pid,
      "title": title,
      "createTime": createTime.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! Folder) {
      return false;
    }
    return title == other.title;
  }

  @override
  int get hashCode => title.hashCode;

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

class Link extends BookMark {
  String? url;
  Uint8List? favicon;

  Link({
    required this.url,
    this.favicon,
    required super.title,
    required super.pid,
  });

  Link.fromMap(Map map) : super(pid: map['pid'],title: map['title']) {
    id = map["id"];
    url = map['url'];
    favicon = map['favicon'] != null
        ? Uint8List.fromList(((map['favicon']) as String).codeUnits)
        : null;
    createTime = DateTime.parse(map['createTime']!);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Link) {
      return false;
    }
    return url == other.url;
  }

  @override
  int get hashCode => url.hashCode;

  update(Link link) {
    if (link.title != null) {
      title = link.title;
    }
    if (link.favicon != null) {
      favicon = link.favicon;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "pid": pid,
      "url": url,
      "title": title,
      "createTime": createTime.toIso8601String(),
      "favicon": favicon != null ? String.fromCharCodes(favicon!) : null,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

List<BookMark> getBookMarksFromHtmlStr(String value) {
  Document document = parse(value);
  Element? root = document.querySelector('dl');
  List<BookMark> list;
  if (root != null) {
    list = walkBookmarksTree(root);
  } else {
    list = [];
  }
  return list;
}

List<BookMark> walkBookmarksTree(Element root) {
  List<BookMark> result = [];
  walk(Element node, String pid) {
    List<Element>? els = node.children;
    if (els.isNotEmpty) {
      for (int i = 0; i < els.length; i++) {
        Element item = els[i];
        if (item.localName == 'p' || item.localName == 'h3') {
          continue;
        }
        if (item.localName == 'dl') {
          walk(els[i], pid);
        } else {
          BookMark child;
          List<Element> children = item.children;
          bool isDir = false;
          for (int j = 0; j < children.length; j++) {
            if (children[j].localName == 'h3' ||
                children[j].localName == 'dl') {
              isDir = true;
            }
          }
          if (isDir) {
            child = Folder(
              title: item.localName == 'dt'
                  ? item.querySelector('h3')?.text
                  : null,
              pid: pid,
            );
            walk(els[i], child.id);
          } else {
            Element? itemTemp = item.querySelector('a');
            LinkedHashMap<Object, String>? attributes = itemTemp?.attributes;
            child = Link(
              title: itemTemp?.text,
              url: attributes?['href'],
              favicon: attributes?['icon'] != null
                  ? UriData.parse(attributes!['icon']!).contentAsBytes()
                  : null,
              pid: pid,
            );
          }
          result.add(child);
        }
      }
    }
  }

  walk(root, 'root');
  return result;
}
