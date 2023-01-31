import 'package:flutter/material.dart';

class StatusModel with ChangeNotifier {
  bool _inAdd = false;
  bool get inAdd => _inAdd;
  set inAdd(bool value) {
    if (value != _inAdd) {
      _inAdd = value;
      notifyListeners();
    }
  }
}
