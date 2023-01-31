import 'dart:typed_data';

class HistoryRecord {
  String? url;
  String? title;
  late DateTime createTime;
  Uint8List? favicon;

  HistoryRecord({
    required this.url,
    required this.title,
    required this.createTime,
    required this.favicon,
  });

  HistoryRecord.fromMap(Map map) {
    url = map['url'];
    title = map["title"];
    favicon = map['favicon'] != null
        ? Uint8List.fromList(((map['favicon']) as String).codeUnits)
        : null;
    createTime = DateTime.parse(map['createTime']!);
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "title": title,
      "createTime": createTime.toIso8601String(),
      "favicon": favicon != null ? String.fromCharCodes(favicon!) : null,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  bool operator ==(Object other) {
    if (other is! HistoryRecord) {
      return false;
    }
    return url == other.url;
  }

  @override
  int get hashCode => url.hashCode;
}