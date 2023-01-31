import 'package:flutter/material.dart';

class CommonUtil{

  static final navigatorKey = GlobalKey<NavigatorState>();

  static double get defaultPadding => 12;

  static double get searchBarHeight => 56.0;

  static double get bottomBarHeight => 64.0;

  static String get suggestionsApi => "https://www.baidu.com/su?&ie=UTF-8&action=opensearch&p=3&wd=";
}