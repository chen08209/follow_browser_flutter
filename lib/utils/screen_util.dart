import 'package:flutter/material.dart';
import 'dart:ui' as ui show window;

class ScreenUtil {
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  double _screenDensity = 0.0;
  double _statusBarHeight = 0.0;
  double _navigationBarHeight = 0.0;
  double _appBarHeight = 0.0;
  MediaQueryData? _mediaQueryData;

  static final ScreenUtil _singleton = ScreenUtil();

  static ScreenUtil getInstance() {
    _singleton._init();
    return _singleton;
  }

  _init() {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (_mediaQueryData != mediaQuery) {
      _mediaQueryData = mediaQuery;
      _screenWidth = mediaQuery.size.width;
      _screenHeight = mediaQuery.size.height;
      _screenDensity = mediaQuery.devicePixelRatio;
      _statusBarHeight = mediaQuery.padding.top;
      _navigationBarHeight = mediaQuery.padding.bottom;
      _appBarHeight = kToolbarHeight;
    }
  }

  double get screenWidth => _screenWidth;

  double get screenHeight => _screenHeight;

  double get appBarHeight => _appBarHeight;

  double get screenDensity => _screenDensity;

  double get statusBarHeight => _statusBarHeight;

  double get navigationBarHeight => _navigationBarHeight;

  MediaQueryData? get mediaQueryData => _mediaQueryData;

  static double getCurrentScreenW(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width;
  }

  static double getCurrentScreenH(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height;
  }

  static double getCurrentScreenDensity(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.devicePixelRatio;
  }

  static double getCurrentStatusBarH(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.top;
  }

  static double getCurrentNavigationBarH(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.bottom;
  }

  static MediaQueryData getMediaQueryData(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery;
  }
}
