import 'package:flutter/material.dart';

class ThemeUtil{

  BuildContext? context;
  Brightness? brightness;

  ThemeUtil(this.context);

  ThemeUtil.brightness(Brightness this.brightness);

  bool get isDark{
    if(context != null){
      return Theme.of(context!).brightness == Brightness.dark;
    }else{
      return brightness == Brightness.dark;
    }
  }

  Color get textPrimaryColor {
    return isDark ? Colors.white :  Colors.black;
  }

  Color get textSecondaryColor {
    return isDark ? Colors.white60 : Colors.black54;
  }

  Color get textInactivationColor {
    return isDark ? Colors.white38 : Colors.black38;
  }
}