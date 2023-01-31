import 'package:flutter/material.dart';

import 'default_scheme.dart';

class Scheme {

  ColorScheme? lightDynamic;
  ColorScheme? darkDynamic;

  Scheme({this.lightDynamic,this.darkDynamic});

  ColorScheme getLightScheme(){
    return lightDynamic ?? defaultLightScheme;
  }

  ColorScheme getDarkScheme(){
    return darkDynamic ?? defaultDarkScheme;
  }
}
